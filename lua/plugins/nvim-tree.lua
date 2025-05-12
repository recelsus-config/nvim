return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,

    keys = {
      { mode = "n", "<C-e>", "<cmd>:Ex<cr>", desc = "Toggle Nvim-Tree Window on Left" },
    },

    config = function()
      require('nvim-tree').setup({
        filters = {
          dotfiles = false,
          custom = {},
        },
        git = {
          ignore = false,
        },
      })
      vim.api.nvim_set_var('loaded_netrw', 1)
      vim.api.nvim_set_var('loaded_netrwPlugin', 1)
      vim.api.nvim_create_user_command('Ex', function ()
      vim.cmd('NvimTreeToggle')
      end, {})
    end
  }
}
