return {
  {
    "supermaven-inc/supermaven-nvim",
    init = function()
      local supermaven_enabled = false

      local function setup_supermaven()
        require("supermaven-nvim").setup({
          keymaps = {
            -- accept_suggestion = "<Tab>",
            -- clear_suggestion = "<C-]>",
            -- accept_word = "<C-j>",
          },
          ignore_filetypes = { "env", "secret" },
          color = {
            suggestion_color = "#808080",
            cterm = 244,
          },
          log_level = "info",
          disable_inline_completion = true,
          disable_keymaps = true
        })
        vim.notify("🚀 Supermaven configured", vim.log.levels.INFO)
        supermaven_enabled = true
      end

      local function disable_supermaven()
        require("supermaven-nvim").setup({})
        vim.notify("Supermaven disabled", vim.log.levels.INFO)
        supermaven_enabled = false
      end

      vim.api.nvim_create_user_command('SupermavenToggle', function()
        if supermaven_enabled then
          disable_supermaven()
        else
          setup_supermaven()
        end
      end, {})

      -- キーマップを追加
      vim.keymap.set('n', '<Leader>sm', ':SupermavenToggle<CR>', { desc = 'Toggle Supermaven' })
    end,
  },
}
