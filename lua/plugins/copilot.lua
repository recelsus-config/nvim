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
      vim.keymap.set('n', '<leader>cs', function()
        require('config.copilot_style').toggle_snake_case_hint()
      end, { noremap = true, silent = true, desc = 'ai: hint' })
    end,

    dependencies = {
      {
        "zbirenbaum/copilot-cmp",
        config = function()
          require("copilot_cmp").setup()
        end,
      },
    },
  },
}
