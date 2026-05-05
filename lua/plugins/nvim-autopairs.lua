return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require('nvim-autopairs')
      npairs.setup({
        -- Avoid interfering with completion confirm mappings
        map_cr = false,
      })
    end,
  }
}
