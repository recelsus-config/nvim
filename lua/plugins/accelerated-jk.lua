return {
  {
    "rainbowhxch/accelerated-jk.nvim",
    event = "BufReadPost",
    config = function()
      vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_gj)', { silent = true })
      vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_gk)', { silent = true })

      require("accelerated-jk").setup({
        mode = "time_driven",
        enable_deceleration = false,
        acceleration_limit = 150,
        acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
        deceleration_table = { { 150, 9999 } }
      })
    end,
  }
}

