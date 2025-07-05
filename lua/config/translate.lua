local ai = require("config.ai")

local function translate_visual_selection()
  local bufnr = 0
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")

  local lines = vim.api.nvim_buf_get_text(bufnr,
    start_pos[1] - 1, start_pos[2],
    end_pos[1] - 1, end_pos[2] + 1,
    {}
  )

  if not lines or #lines == 0 then
    print("No text selected.")
    return
  end

  local text_to_translate = table.concat(lines, "\n")
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
  local translated = ai.send_ai_request(prompt)

  if translated then
    print("[Translated]: " .. translated)
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

  local translated = ai.send_ai_request(prompt)
  if translated then
    print("[Translated Diagnostic + Suggestion]:\n" .. translated)
  end
end

vim.keymap.set('n', '<leader>td', translate_diagnostic_message, { noremap = true, silent = true, desc = "[LSP] Translate Diagnostic Message" })
vim.keymap.set('v', '<leader>td', translate_visual_selection, { noremap = true, silent = true, desc = "[LSP] Translate Visual Selection" })

