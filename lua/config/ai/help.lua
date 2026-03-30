local ai = require("config.ai")

local function show_in_split(title, body)
  vim.cmd("botright 12split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  local lines = {}
  if title and title ~= "" then
    table.insert(lines, title)
    table.insert(lines, string.rep("-", math.max(10, #title)))
    table.insert(lines, "")
  end

  for _, line in ipairs(vim.split(tostring(body or ""), "\n", { plain = true })) do
    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"
end

local function format_diagnostic(diagnostic)
  local code = diagnostic.code or (diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code)
  local source = diagnostic.source or (diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.source)
  local src_str = source and (" [" .. tostring(source) .. "]") or ""
  local code_str = code and (" [" .. tostring(code) .. "]") or ""
  return string.format("- Line %d%s%s: %s", diagnostic.lnum + 1, src_str, code_str, diagnostic.message)
end

local function collect_buffer_context()
  local bufnr = 0
  local fpath = vim.api.nvim_buf_get_name(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if #diagnostics == 0 then
    return nil, "No diagnostics found in the current buffer."
  end

  local diagnostic_lines = {}
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(diagnostic_lines, format_diagnostic(diagnostic))
  end

  return {
    path = fpath,
    diagnostics = table.concat(diagnostic_lines, "\n"),
    buffer = table.concat(lines, "\n"),
  }, nil
end

local function request_help(language)
  local context, err = collect_buffer_context()
  if not context then
    vim.notify(err, vim.log.levels.INFO)
    return
  end

  local prompt
  local title
  if language == "ja" then
    title = "LSP Help (JA)"
    prompt = string.format([[
Analyze the following buffer and its LSP diagnostics.

Answer in Japanese.
Keep the answer concise.
Explain:
1. The most likely root cause.
2. A practical fix.

Do not repeat the full source code.
Do not be verbose.

File:
%s

Diagnostics:
%s

Buffer:
%s
]], context.path, context.diagnostics, context.buffer)
  else
    title = "LSP Help (EN)"
    prompt = string.format([[
Analyze the following buffer and its LSP diagnostics.

Answer in English.
Keep the answer concise.
Explain:
1. The most likely root cause.
2. A practical fix.

Do not repeat the full source code.
Do not be verbose.

File:
%s

Diagnostics:
%s

Buffer:
%s
]], context.path, context.diagnostics, context.buffer)
  end

  local answer, request_err = ai.send_ai_request(prompt)
  if answer then
    show_in_split(title, answer)
  else
    show_in_split("AI Error", request_err or "Failed to get response from AI API")
  end
end

vim.keymap.set("n", "<leader>hj", function()
  request_help("ja")
end, { noremap = true, silent = true, desc = "help: diag ja" })

vim.keymap.set("n", "<leader>he", function()
  request_help("en")
end, { noremap = true, silent = true, desc = "help: diag en" })
