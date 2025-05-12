return {
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      floating_window = true,
      handler_opts = {
        border = "single",
      },
      hint_enable = false,
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}

