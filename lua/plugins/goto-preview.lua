return {
  {
    "rmagatti/goto-preview",
    dependencies = {
      "rmagatti/logger.nvim",
    },
    event = "BufReadPre",
    config = function()
      require("goto-preview").setup({
        border = { "+", "-", "+", "|", "+", "-", "+", "|" },
        default_mappings = false,
        focus_on_open = false,
        dismiss_on_move = true,
      })

      vim.keymap.set("n", "<leader>lp", function()
        require("goto-preview").goto_preview_type_definition()
      end, { noremap = true, silent = true, desc = "lsp: type preview" })
    end,
  },
}
