local ai = require("config.ai")

local function show_in_split(title, body)
  vim.cmd("botright 12split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  local lines = {}
  if title and title ~= '' then
    table.insert(lines, title)
    table.insert(lines, string.rep('-', math.max(10, #title)))
    table.insert(lines, '')
  end

  for _, l in ipairs(vim.split(tostring(body or ''), "\n", { plain = true })) do
    table.insert(lines, l)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"
end

local function translate_visual_selection()
  local bufnr = 0
  local mode = vim.fn.mode()
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, '<'))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, '>'))

  -- normalize order (1-based to 0-based later)
  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow, scol, ecol = erow, srow, ecol, scol
  end

  local text_to_translate
  if mode == 'V' then
    -- linewise selection
    local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
    text_to_translate = table.concat(lines, '\n')
  else
    -- characterwise (and others): prefer exact text range
    local parts = vim.api.nvim_buf_get_text(bufnr, srow - 1, scol - 1, erow - 1, ecol, {})
    if parts and #parts > 0 then
      text_to_translate = table.concat(parts, '\n')
    else
      -- fallback to linewise if empty
      local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
      text_to_translate = table.concat(lines, '\n')
    end
  end

  if not text_to_translate or text_to_translate == '' then
    print('No text selected.')
    return
  end
  local prompt = string.format([[
    Translate the following text into Japanese.

    The text may include lines of code or other irrelevant parts.
    Please ignore any surrounding code and extract only the core message inside quotes
    (such as within "double quotes", 'single quotes', or `backticks`),
    and translate that part only.

    Output exactly one concise and natural Japanese sentence.
    Do not include explanations or alternative options.
    If no quoted text is found, you may attempt to translate any meaningful English sentence found in the selection.

    Text:
    %s
  ]], text_to_translate)
  local translated, err = ai.send_ai_request(prompt)
  if translated then
    show_in_split("Translated Selection", translated)
  else
    show_in_split("AI Error", err or "Failed to get response from AI API")
  end
end

local function translate_diagnostic_message()
  local bufnr = 0
  local lnum = vim.fn.line('.') - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

  if #diagnostics == 0 then
    print("No diagnostics available at the current cursor position.")
    return
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
  local message = diagnostics[1].message

  local prompt = string.format([[
    Translate the following LSP diagnostic message into Japanese.
    Include the code line for context.
    Then, if possible, suggest a brief possible solution (no more than one line).

    Return a single natural Japanese sentence for the error message,
    followed by an optional suggestion in Japanese starting with "解決策: ".

    Code:
    %s

    Diagnostic message:
    %s
  ]], line, message)

  local translated, err = ai.send_ai_request(prompt)
  if translated then
    show_in_split("Translated Diagnostic", translated)
  else
    show_in_split("AI Error", err or "Failed to get response from AI API")
  end
end

vim.keymap.set('n', '<leader>td', translate_diagnostic_message, { noremap = true, silent = true, desc = "translate: diag" })
vim.keymap.set('v', '<leader>td', translate_visual_selection,   { noremap = true, silent = true, desc = "translate: selection" })
