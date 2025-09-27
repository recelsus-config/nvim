return {
  {
    -- Neovim 0.11+ native LSP config/start (no nvim-lspconfig)
    "williamboman/mason.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()

      -- Global diagnostic keymaps
      vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = "lsp: diag float", noremap = true, silent = true })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "lsp: prev diag", noremap = true, silent = true })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "lsp: next diag", noremap = true, silent = true })

      -- Buffer-local LSP setup via LspAttach (Neovim 0.11+ style)
      local aug = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = aug,
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- omnifunc for completion fallback
          vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

          local function buf_map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          buf_map('n', 'K',  vim.lsp.buf.hover,         'lsp: hover')
          buf_map('n', 'gd', vim.lsp.buf.definition,    'lsp: goto def')
          buf_map('n', 'gi', vim.lsp.buf.implementation, 'lsp: goto impl')
          buf_map('n', 'gr', vim.lsp.buf.references,    'lsp: refs')
          buf_map('n', 'gs', vim.lsp.buf.signature_help,'lsp: signature')

          -- LSP utilities
          buf_map('n', '<leader>lr', vim.lsp.buf.rename,       'lsp: rename')
          buf_map('n', '<leader>la', vim.lsp.buf.code_action,  'lsp: action')
          buf_map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'lsp: format')

          -- Enable inlay hints by default if supported; add toggle
          if client and client.server_capabilities and client.server_capabilities.inlayHintProvider then
            local ok = pcall(function() vim.lsp.inlay_hint.enable(bufnr, true) end)
            if not ok then pcall(function() vim.lsp.inlay_hint(bufnr, true) end) end

            buf_map('n', '<leader>ih', function()
              local ih = vim.lsp.inlay_hint
              if ih.is_enabled then
                local enabled = ih.is_enabled(bufnr)
                ih.enable(bufnr, not enabled)
              else
                local enabled = vim.b.inlay_hints_enabled or true
                ih(bufnr, not enabled)
                vim.b.inlay_hints_enabled = not enabled
              end
            end, 'lsp: inlay toggle')
          end
        end,
      })

      -- Centralize capabilities for all servers
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Helpers -------------------------------------------------------------
      local function root_pattern(markers)
        return function(fname)
          fname = fname or vim.api.nvim_buf_get_name(0)
          local start = vim.fs.dirname(fname ~= '' and fname or vim.fn.getcwd())
          local found = vim.fs.find(markers, { path = start, upward = true })[1]
          return found and vim.fs.dirname(found) or vim.fn.getcwd()
        end
      end

      local function with_capabilities(cfg)
        return vim.tbl_deep_extend('force', { capabilities = capabilities }, cfg or {})
      end

      -- Server definitions (minimal, extendable via lua/lsp/servers/*.lua) --
      local base_servers = {
        lua_ls = with_capabilities({
          name = 'lua_ls',
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_dir = root_pattern({ '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', '.git' }),
          settings = {},
        }),

        ts_ls = with_capabilities({
          name = 'ts_ls',
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
          root_dir = root_pattern({ 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' }),
          settings = {},
        }),

        bashls = with_capabilities({
          name = 'bashls',
          cmd = { 'bash-language-server', 'start' },
          filetypes = { 'sh' },
          root_dir = root_pattern({ '.git' }),
          settings = {},
        }),

        clangd = with_capabilities({
          name = 'clangd',
          cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=bundled', '--fallback-style=LLVM' },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          root_dir = root_pattern({ 'compile_commands.json', 'compile_flags.txt', '.git' }),
          settings = {},
        }),
      }

      -- Merge user overrides from lua/lsp/servers/<name>.lua ----------------
      local function load_user_opts(name)
        local ok, mod = pcall(require, 'lsp')
        if ok and type(mod.get) == 'function' then
          local custom = mod.get(name)
          if custom and type(custom) == 'table' then return custom end
        end
      end

      for name, _ in pairs(base_servers) do
        local user = load_user_opts(name)
        if user then
          base_servers[name] = vim.tbl_deep_extend('force', base_servers[name], user)
        end
      end

      -- Only start servers the user actually has installed via Mason --------
      local installed = {}
      for _, s in ipairs(require('mason-lspconfig').get_installed_servers()) do
        installed[s] = true
      end
      -- Compatibility alias: tsserver <-> ts_ls
      if installed['tsserver'] and not installed['ts_ls'] then installed['ts_ls'] = true end

      -- Build FileType -> servers index
      local ft_index = {}
      for name, cfg in pairs(base_servers) do
        if installed[name] then
          for _, ft in ipairs(cfg.filetypes or {}) do
            ft_index[ft] = ft_index[ft] or {}
            table.insert(ft_index[ft], { name = name, cfg = cfg })
          end
        end
      end

      -- Autostart per buffer when a matching filetype opens -----------------
      local function start_for_buf(bufnr, item)
        -- Avoid duplicate start for same server on this buffer
        local existing = vim.lsp.get_clients({ bufnr = bufnr, name = item.name })
        if existing and #existing > 0 then return end

        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = item.cfg.root_dir and item.cfg.root_dir(fname) or vim.fn.getcwd()
        local final = vim.tbl_deep_extend('force', item.cfg, { name = item.name, root_dir = root })

        -- Normalize config via vim.lsp.config (Neovim 0.11+)
        local ok_cfg, normalized = pcall(vim.lsp.config, final)
        local to_start = ok_cfg and normalized or final
        vim.lsp.start(to_start, { bufnr = bufnr })
      end

      local grp = vim.api.nvim_create_augroup('user_lsp_autostart', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = grp,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local items = ft_index[ft]
          if not items then return end
          for _, item in ipairs(items) do
            start_for_buf(args.buf, item)
          end
        end,
      })
    end,
  },
}
