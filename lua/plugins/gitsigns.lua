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

      vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', { noremap = true, silent = true, desc = "[Git] Show Git blame for current line" })
      vim.api.nvim_set_keymap('n', '<leader>gB', '<cmd>Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true, desc = "[Git] Toggle Git blame for current line" })
      vim.api.nvim_set_keymap('n', '<leader>gd', '<cmd>Gitsigns toggle_deleted<CR>', { noremap = true, silent = true, desc = "[Git] Toggle showing deleted lines" })
      vim.api.nvim_set_keymap('n', '<leader>gD', '<cmd>Gitsigns diffthis<CR>', { noremap = true, silent = true, desc = "[Git] Preview file or line diff" })
    end
  }
}

