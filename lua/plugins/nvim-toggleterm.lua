return {
  {
    "akinsho/toggleterm.nvim",
    lazy = false,

    config = function()
      local toggleterm = require("toggleterm")
      local Terminal = require("toggleterm.terminal").Terminal

      local term_config = {
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.3)
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
        end,
        open_mapping = [[<C-t>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "single",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      }

      toggleterm.setup(term_config)

      local float_term = Terminal:new({
        direction = "float",
        close_on_exit = true,
        hidden = true,
        float_opts = {
          width = 120,
          height = 30,
          row = function()
            return vim.o.lines - 20 - 2
          end,
          col = function()
            return vim.o.columns - 80 - 2
          end,
          border = "single",
        },
      })

      vim.keymap.set("n", "<S-t>", function()
        float_term:toggle()
      end, {
        noremap = true,
        silent = true,
        desc = "Toggle Float Terminal",
      })
    end,
  },
}

