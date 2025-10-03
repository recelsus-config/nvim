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
      wk.add({ "<leader>c", desc = "Comment", icon = "󰚰" })
      wk.add({ "<leader>m", desc = "Msg", icon = "" })

      -- Sub-entries to ensure visibility in which-key
      wk.add({ "<leader>yd", desc = "diag: yank line", mode = "n" })
      wk.add({ "<leader>yad", desc = "diag: yank all", mode = "n" })
      wk.add({ "<leader>ys", desc = "diag: yank sel", mode = "v" })

      wk.add({ "<leader>lr", desc = "lsp: rename", mode = "n" })
      wk.add({ "<leader>la", desc = "lsp: action", mode = "n" })
      wk.add({ "<leader>lf", desc = "lsp: format", mode = "n" })

      wk.add({ "<leader>cs", desc = "ai: hint", mode = "n" })
      wk.add({ "<leader>cb", desc = "comment: box", mode = "n" })
      wk.add({ "<leader>cb", desc = "comment: box", mode = "v" })
    end
  }
}
