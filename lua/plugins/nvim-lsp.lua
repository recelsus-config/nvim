return {
  {
    -- Neovim 0.11+ native LSP config/start (no nvim-lspconfig)
    "williamboman/mason.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()

      -- Global diagnostic keymaps
      vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, { desc = "lsp: diag float", noremap = true, silent = true })
      vim.keymap.set('n', '[d', function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, { desc = "lsp: prev diag", noremap = true, silent = true })
      vim.keymap.set('n', ']d', function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, { desc = "lsp: next diag", noremap = true, silent = true })

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

          local function supports(method)
            if not client then return false end
            if type(client.supports_method) == 'function' then
              local ok, supported = pcall(client.supports_method, client, method, bufnr)
              if ok then return supported end
              ok, supported = pcall(client.supports_method, client, method)
              if ok then return supported end
            end
            return false
          end

          local function hover()
            vim.lsp.buf.hover({
              border = 'rounded',
              focusable = true,
              max_width = 120,
              max_height = 30,
              title = ' LSP Hover ',
              title_pos = 'center',
            })
          end

          local function type_definition_in_split(split_cmd)
            vim.lsp.buf.type_definition({
              on_list = function(options)
                if not options.items or vim.tbl_isempty(options.items) then
                  vim.notify('No type definition found', vim.log.levels.INFO)
                  return
                end

                vim.fn.setqflist({}, ' ', {
                  title = options.title or 'LSP type definition',
                  items = options.items,
                })
                vim.cmd(split_cmd)
                vim.cmd.cfirst()
              end,
            })
          end

          buf_map('n', 'K', hover, 'lsp: hover')

          -- LSP navigation/utilities
          if supports('textDocument/definition') then
            buf_map('n', '<leader>ld', vim.lsp.buf.definition, 'lsp: definition')
          end
          if supports('textDocument/declaration') then
            buf_map('n', '<leader>lD', vim.lsp.buf.declaration, 'lsp: declaration')
          end
          if supports('textDocument/typeDefinition') then
            buf_map('n', '<leader>lt', vim.lsp.buf.type_definition, 'lsp: type definition')
            buf_map('n', '<leader>lx', function()
              type_definition_in_split('split')
            end, 'lsp: type definition split')
            buf_map('n', '<leader>lv', function()
              type_definition_in_split('vsplit')
            end, 'lsp: type definition vsplit')
          end
          if supports('textDocument/implementation') then
            buf_map('n', '<leader>lm', vim.lsp.buf.implementation, 'lsp: implementation')
          end
          if supports('textDocument/references') then
            buf_map('n', '<leader>lR', vim.lsp.buf.references, 'lsp: references')
          end
          if supports('textDocument/signatureHelp') then
            buf_map('n', '<leader>ls', vim.lsp.buf.signature_help, 'lsp: signature')
          end
          if supports('textDocument/rename') then
            buf_map('n', '<leader>lr', vim.lsp.buf.rename, 'lsp: rename')
          end
          if supports('textDocument/codeAction') then
            buf_map('n', '<leader>la', vim.lsp.buf.code_action, 'lsp: action')
          end
          if supports('textDocument/formatting') then
            buf_map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'lsp: format')
          end

          -- Enable inlay hints by default if supported; add toggle
          if client and client.server_capabilities and client.server_capabilities.inlayHintProvider then
            local ih = vim.lsp.inlay_hint
            local function ih_enable(buf, enable)
              if ih and ih.enable then
                if pcall(ih.enable, enable, { bufnr = buf }) then return true end
                if pcall(ih.enable, buf, enable) then return true end
              end
              if type(ih) == 'function' then
                return pcall(ih, buf, enable)
              end
              return false
            end
            local function ih_is_enabled(buf)
              if ih and ih.is_enabled then
                local ok, val = pcall(ih.is_enabled, { bufnr = buf })
                if ok and type(val) == 'boolean' then return val end
                ok, val = pcall(ih.is_enabled, buf)
                if ok and type(val) == 'boolean' then return val end
              end
              return false
            end

            ih_enable(bufnr, true)

            buf_map('n', '<leader>li', function()
              local cur = ih_is_enabled(bufnr)
              ih_enable(bufnr, not cur)
            end, 'lsp: inlay toggle')
          end
        end,
      })

      -- Centralize completion capabilities for all servers
      local capabilities = require('blink.cmp').get_lsp_capabilities()

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

        pyright = with_capabilities({
          name = 'pyright',
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
          root_dir = root_pattern({ 'pyproject.toml', 'setup.cfg', 'setup.py', 'requirements.txt', '.git' }),
          settings = {},
        }),
      }

      -- Merge user overrides from lua/lsp/servers/<name>.lua ----------------
      local function load_user_opts(name)
        local ok, mod = pcall(require, 'lsp')
        if ok and type(mod) == 'table' and type(mod.get) == 'function' then
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

        vim.lsp.start(final, { bufnr = bufnr })
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
