return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-s>"] = { "show" },
        ["<C-d>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              label = {
                width = { fill = true, max = 80 },
              },
              label_description = {
                width = { max = 50 },
              },
              source_name = {
                width = { max = 20 },
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            max_width = 100,
            max_height = 30,
          },
        },
        ghost_text = { enabled = true },
      },
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "show", "accept" },
        },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },
}
