return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
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

      -- LSP setup for all installed servers
      local lspconfig = require("lspconfig")
      local servers = require("mason-lspconfig").get_installed_servers()

      for _, server_name in ipairs(servers) do
        local opts = { capabilities = capabilities }
        local ok, mod = pcall(require, 'lsp')
        if ok and type(mod.get) == 'function' then
          local custom = mod.get(server_name)
          if custom and type(custom) == 'table' then
            opts = vim.tbl_deep_extend('force', opts, custom)
          end
        end
        lspconfig[server_name].setup(opts)
      end
    end,
  },
}
