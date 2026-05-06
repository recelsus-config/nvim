local function start_treesitter(args)
  local bufnr = args.buf
  local filetype = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(filetype)

  if not lang then
    return
  end

  local ok, loaded = pcall(vim.treesitter.language.add, lang)
  if not ok or not loaded then
    return
  end

  local started = pcall(vim.treesitter.start, bufnr, lang)
  if not started then
    return
  end

  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  vim.wo.foldmethod = "expr"
  vim.wo.foldlevel = 99
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = start_treesitter,
})
