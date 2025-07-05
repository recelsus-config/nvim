return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()

      -- Global diagnostic keymaps
      vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = "[LSP] Show Diagnostics", noremap = true, silent = true })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "[LSP] Go to Previous Diagnostic", noremap = true, silent = true })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "[LSP] Go to Next Diagnostic", noremap = true, silent = true })

      local on_attach = function(_, bufnr)
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
        }, bufnr)

        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "[LSP] Show Hover Info", buffer = bufnr })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "[LSP] Go to Definition", buffer = bufnr })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "[LSP] Go to Implementation", buffer = bufnr })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "[LSP] Find References", buffer = bufnr })
        vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, { desc = "[LSP] Show Signature Help", buffer = bufnr })
      end

      -- LSP setup for all installed servers
      local lspconfig = require("lspconfig")
      local servers = require("mason-lspconfig").get_installed_servers()

      for _, server_name in ipairs(servers) do
        lspconfig[server_name].setup({
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          on_attach = on_attach,
        })
      end

      -- Completion setup
      local cmp = require("cmp")

      cmp.setup({
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-s>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_document_symbol' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'copilot' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
}

