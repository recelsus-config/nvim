return {
  {
    "lewis6991/gitsigns.nvim",
    event = 'BufReadPre',
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
        },

        watch_gitdir = {
          interval = 1000,
        },

        current_line_blame = false,
        current_line_blame_opts = {
          virt_text_pos = 'eol',
          delay = 1000,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',

        numhl = true,
        linehl = false
      })

      vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true, desc = "git: blame toggle" })
      vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>',                  { noremap = true, silent = true, desc = "git: diff" })
    end
  }
}
