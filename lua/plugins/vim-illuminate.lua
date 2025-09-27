return {
  {
    "RRethy/vim-illuminate",
    event = "BufReadPre",

    config = function()
      require('illuminate').configure({
        delay = 100,
        filetypes_denylist = { 'NvimTree', 'alpha' },
        under_cursor = true,
      })
    end
  }
}
