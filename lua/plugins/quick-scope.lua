return {
  {
    "unblevable/quick-scope",
    event = 'BufReadPre',

    config = function()
      vim.g.qs_highlight_on_keys = {'f', 'F', 't', 'T'}

      vim.cmd([[
        highlight QuickScopePrimary guifg='#afff5f' gui=bold ctermfg=155 cterm=bold
        highlight QuickScopeSecondary guifg='#5fffff' gui=bold ctermfg=81 cterm=bold
      ]])
    end
  }
}
