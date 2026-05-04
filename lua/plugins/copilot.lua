return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",

    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        copilot_node_command = 'node'
      })
      -- Helper to toggle style hint (snake_case) at top of buffer
      vim.keymap.set('n', '<leader>ch', function()
        require('config.copilot_style').toggle_snake_case_hint()
      end, { noremap = true, silent = true, desc = 'comment: ai hint' })
    end,

    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        config = function()
          local source = require("copilot_cmp.source")
          source.is_available = function(self)
            if self.client:is_stopped() or self.client.name ~= "copilot" then
              return false
            end
            local clients = vim.lsp.get_clients({
              bufnr = vim.api.nvim_get_current_buf(),
              id = self.client.id,
            })
            return next(clients) ~= nil
          end
          require("copilot_cmp").setup()
        end,
      },
    },
  },
}
