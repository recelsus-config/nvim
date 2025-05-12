return {
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
          auto_scroll = false,
          show_header_separator = true,
        },
      },

      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-2.0-flash",
              },
              language = {
                default = "Japanese",
              },
            },
          })
        end,
      },

      strategies = {
        chat = {
          adapter = 'gemini',
          slash_commands = {
            ["buffer"] = {
              opts = { provider = "telescope" },
            },
            ["file"] = {
              opts = { provider = "telescope" },
            },
            ["help"] = {
              opts = { provider = "telescope" },
            },
            ["symbols"] = {
              opts = { provider = "telescope" },
            },
            ["workspace"] = {
              opts = { provider = "telescope" },
            },
          },
        },
        inline = {
          adapter = 'gemini',
        },
      },
    }
  end
}
