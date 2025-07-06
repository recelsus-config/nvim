return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        trim_scope = "outer",
        mode = "cursor",
        separator = "-",
        zindex = 20,
        on_attach = nil
      })

      -- vim.keymap.set('n', '<leader>tc', function()
      --   vim.cmd("TSContextToggle")
      -- end, { desc = "[TS] Toggle Treesitter Context", silent = true })
    end
  }
}

