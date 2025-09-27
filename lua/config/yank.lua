local function yank_diagnostic_message()
  local bufnr = 0
  local lnum = vim.fn.line('.') - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

  if #diagnostics == 0 then
    print("No diagnostics available at the current cursor position.")
    return
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
  local fpath = vim.api.nvim_buf_get_name(bufnr)

  local message = diagnostics[1].message
  local code = diagnostics[1].code or (diagnostics[1].user_data and diagnostics[1].user_data.lsp and diagnostics[1].user_data.lsp.code)
  local source = diagnostics[1].source or (diagnostics[1].user_data and diagnostics[1].user_data.lsp and diagnostics[1].user_data.lsp.source)
  local src_str = source and (" [" .. tostring(source) .. "]") or ""
  local code_str = code and (" [" .. tostring(code) .. "]") or ""

  local combined = string.format("%s:%d\n%s\n-- Diagnostic%s%s: %s", fpath, lnum + 1, line, src_str, code_str, message)
  vim.fn.setreg("+", combined)

  print("Path, line and diagnostic yanked:")
  print(combined)
end

vim.keymap.set('n', '<leader>yd', yank_diagnostic_message, { noremap = true, silent = true, desc = "diag: yank" })

local function yank_all_diagnostics_with_code()
  local bufnr = 0
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local result = {}
  local fpath = vim.api.nvim_buf_get_name(bufnr)

  table.insert(result, fpath)
  table.insert(result, "")

  for lnum = 0, line_count - 1 do
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

    if #diagnostics > 0 then
      local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
      table.insert(result, string.format("%d: %s", lnum + 1, line))

      for _, d in ipairs(diagnostics) do
        local code = d.code or (d.user_data and d.user_data.lsp and d.user_data.lsp.code)
        local source = d.source or (d.user_data and d.user_data.lsp and d.user_data.lsp.source)
        local src_str = source and (" [" .. tostring(source) .. "]") or ""
        local code_str = code and (" [" .. tostring(code) .. "]") or ""
        table.insert(result, string.format("-- Diagnostic%s%s: %s", src_str, code_str, d.message))
      end

      table.insert(result, "")
    end
  end

  if #result == 0 then
    print("No diagnostics found in buffer.")
    return
  end

  local text = table.concat(result, "\n")
  vim.fn.setreg("+", text)
  print("Filename and all diagnostics yanked to clipboard.")
end

vim.keymap.set('n', '<leader>yad', yank_all_diagnostics_with_code, { noremap = true, silent = true, desc = "diag: yank all" })
