local function yank_diagnostic_message()
  local bufnr = 0
  local lnum = vim.fn.line('.') - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

  if #diagnostics == 0 then
    print("No diagnostics available at the current cursor position.")
    return
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]

  local message = diagnostics[1].message

  local combined = line .. "\n" .. "-- Diagnostic: " .. message
  vim.fn.setreg("+", combined)

  print("Line and diagnostic message yanked to clipboard:")
  print(combined)
end

vim.keymap.set('n', '<leader>yd', yank_diagnostic_message, { noremap = true, silent = true, desc = "[LSP] Yank Diagnostic Message" })

local function yank_all_diagnostics_with_code()
  local bufnr = 0
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local result = {}

  for lnum = 0, line_count - 1 do
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

    if #diagnostics > 0 then
      local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
      table.insert(result, line)

      for _, d in ipairs(diagnostics) do
        table.insert(result, "-- Diagnostic: " .. d.message)
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
  print("All diagnostics with code lines yanked to clipboard.")
end

vim.keymap.set('n', '<leader>yad', yank_all_diagnostics_with_code, { noremap = true, silent = true, desc = "[LSP] Yank All Diagnostic Message" })

