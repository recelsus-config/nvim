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

      wk.add({ "<leader>e", desc = "LSP", icon = "" })
      wk.add({ "<leader>i", desc = "Inlay", icon = "󰆧" })
      wk.add({ "<leader>l", desc = "LSP", icon = "" })
      wk.add({ "<leader>f", desc = "Find", icon = "" })
      wk.add({ "<leader>g", desc = "Git", icon = "" })
      wk.add({ "<leader>t", desc = "Translate", icon = "" })
      wk.add({ "<leader>y", desc = "Yank", icon = "" })
      wk.add({ "<leader>c", desc = "AI", icon = "󰚰" })
      wk.add({ "<leader>m", desc = "Msg", icon = "" })
    end
  }
}
