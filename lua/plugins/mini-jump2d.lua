return {
  {
    "echasnovski/mini.jump2d",
    version = false,
    event = "BufReadPre",
    config = function()
      require("mini.jump2d").setup({
        labels = "abcdefghijklmnopqrstuvwxyz",
        view = {
          dim = false,
          n_steps_ahead = 0,
        },
        allowed_lines = {
          blank = true,
          cursor_before = true,
          cursor_at = true,
          cursor_after = true,
          fold = true,
        },
        allowed_windows = {
          current = true,
          not_current = true,
        },
        mappings = {
          start_jumping = "",
        },
        silent = false,
      })

      vim.keymap.set("n", "<C-f>", function()
        require("mini.jump2d").start()
      end, { noremap = true, silent = true, desc = "[Jump2d] Jump" })
    end,
  },
}
