local transparent_group = vim.api.nvim_create_augroup('TransparentHighlights', { clear = true })

local function clear_background()
  for _, highlight_name in ipairs(vim.fn.getcompletion('', 'highlight')) do
    local command = string.format('highlight %s guibg=NONE ctermbg=NONE', highlight_name)
    pcall(vim.cmd, command)
  end
end

clear_background()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = transparent_group,
  callback = clear_background,
})
