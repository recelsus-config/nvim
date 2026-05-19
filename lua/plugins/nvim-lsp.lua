return {
  {
    -- Neovim 0.11+ native LSP config/enable
    "williamboman/mason.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_enable = false,
      })

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
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('blink.cmp').get_lsp_capabilities()
      )
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Enable installed servers that have lua/lsp/servers/<name>.lua.
      local lsp_servers = require('lsp')
      local installed = {}
      for _, s in ipairs(require('mason-lspconfig').get_installed_servers()) do
        installed[s] = true
      end

      for _, name in ipairs(lsp_servers.names()) do
        if installed[name] then
          vim.lsp.config(name, lsp_servers.get(name))
          vim.lsp.enable(name)
        end
      end
    end,
  },
}
