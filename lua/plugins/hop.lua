return {
  {
    "smoka7/hop.nvim",
    version = "*",
    event = "BufReadPre",
    config = function()
      local hop = require("hop")

      hop.setup({
        keys = "abcdefghijklmnopqrstuvwxyz",
      })

      vim.keymap.set("n", "<C-f>", function()
        hop.hint_words()
      end, { noremap = true, silent = true, desc = "[Hop] Jump to word" })
    end,
  },
}
