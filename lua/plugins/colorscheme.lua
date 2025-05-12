return {
  {
    "navarasu/onedark.nvim",
    lazy = false,

    config = function()
      require('onedark').setup {
        style = 'warmer'
      }
      vim.cmd('colorscheme onedark')
    end
  }
}
