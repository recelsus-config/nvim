return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup {
        opts = {
          language = "japanese",
        },
        display = {
          chat = {
            auto_scroll = true,
            show_header_separator = true,
          },
        },

        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = { default = "gemini-2.0-flash" },
                language = { default = "Japanese" },
              },
            })
          end,
        },

        strategies = {
          chat = {
            adapter = 'gemini',
            slash_commands = {
              ["buffer"] = { opts = { provider = "telescope" }, },
              ["file"] = { opts = { provider = "telescope" }, },
              ["help"] = { opts = { provider = "telescope" }, },
              ["symbols"] = { opts = { provider = "telescope" }, },
              ["workspace"] = { opts = { provider = "telescope" }, },
            },
            keymaps = {
              send = {
                modes = { n = "<F12>", i = "<F12>" }
              },
            },
          },
          inline = {
            adapter = 'gemini',
          },
        },
      }
      vim.keymap.set({ "n", "v" }, "<Space>cc", "<cmd>CodeCompanionChat<CR>",   { silent = true, noremap = true, desc = "ai: chat" })
      vim.keymap.set({ "n", "v" }, "<Space>cf", "<cmd>CodeCompanion<CR>",       { silent = true, noremap = true, desc = "ai: run" })
      vim.keymap.set({ "n", "v" }, "<Space>ca", "<cmd>CodeCompanionAction<CR>", { silent = true, noremap = true, desc = "ai: action" })
    end,
  }
}
