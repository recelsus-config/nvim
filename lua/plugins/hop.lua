return {
  {
    "smoka7/hop.nvim",
    version = "*",
    event = 'BufReadPre',

    config = function()
      require("hop").setup {
        multi_windows = true,
      }

      vim.keymap.set("n", "<C-f>", "<cmd>HopWord<CR>", { noremap = true, silent = true, desc = "[Hop] Jump to Word" })
    end
  }
}
