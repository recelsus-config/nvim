local transparent_group = vim.api.nvim_create_augroup('TransparentHighlights', { clear = true })

local excluded_groups = {
  Visual = true,
  VisualNOS = true,
}

local function clear_background()
  for _, highlight_name in ipairs(vim.fn.getcompletion('', 'highlight')) do
    if not excluded_groups[highlight_name] then
      local command = string.format('highlight %s guibg=NONE ctermbg=NONE', highlight_name)
      pcall(vim.cmd, command)
    end
  end
end

local function apply_search_highlight()
  local custom_groups = {
    Search = { fg = '#0f0f0f', bg = '#ffe066', bold = true },
    IncSearch = { fg = '#0f0f0f', bg = '#ffca3a', bold = true },
    CurSearch = { fg = '#0f0f0f', bg = '#ffba08', bold = true },
  }

  for name, opts in pairs(custom_groups) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end

local function refresh_highlights()
  clear_background()
  apply_search_highlight()
end

refresh_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = transparent_group,
  callback = refresh_highlights,
})
