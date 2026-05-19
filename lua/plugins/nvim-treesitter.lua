return {
  {
    "neovim-treesitter/nvim-treesitter",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    lazy = false,
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
    },
  },
}
