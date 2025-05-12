return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",

    config = function()
      local wk = require("which-key")

      wk.setup {
        triggers = {
         { "<leader>", mode = "nv" },
        },
        icons = {
          separator = "=>",
          group = "",
        }
      }

      wk.add({ "<leader>e", desc = "LSP Diagnostic", icon = "" })
      wk.add({ "<leader>f", desc = "Telescope", icon = "" })
      wk.add({ "<leader>g", desc = "Git", icon = "" })
      wk.add({ "<leader>t", desc = "Translator", icon = "" })
      wk.add({ "<leader>y", desc = "Yank", icon = "" })

    end
  }
}
