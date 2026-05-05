local ai = require("config.ai")
local REPLACE_TRANSLATION_FAILED = "__NVIM_TRANSLATION_REPLACE_FAILED__"

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

local function get_visual_selection()
  local bufnr = 0
  local current_mode = vim.fn.mode()
  local is_active_visual = current_mode == 'v' or current_mode == 'V' or current_mode == '\022'
  local mode = is_active_visual and current_mode or vim.fn.visualmode()
  local srow, scol, erow, ecol

  if is_active_visual then
    local start_pos = vim.fn.getpos('v')
    local end_pos = vim.fn.getpos('.')
    srow = start_pos[2]
    scol = start_pos[3] - 1
    erow = end_pos[2]
    ecol = end_pos[3] - 1
  else
    srow, scol = unpack(vim.api.nvim_buf_get_mark(bufnr, '<'))
    erow, ecol = unpack(vim.api.nvim_buf_get_mark(bufnr, '>'))
  end

  if srow == 0 or erow == 0 then
    return {
      bufnr = bufnr,
      mode = mode,
      srow = srow,
      scol = scol,
      erow = erow,
      ecol = ecol,
      text = '',
    }
  end

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
    local end_line = vim.api.nvim_buf_get_lines(bufnr, erow - 1, erow, false)[1] or ''
    local end_col = math.min(ecol + 1, #end_line)
    local ok, parts
    ok, parts = pcall(vim.api.nvim_buf_get_text, bufnr, srow - 1, scol, erow - 1, end_col, {})
    if not ok then parts = nil end
    if parts and #parts > 0 then
      text_to_translate = table.concat(parts, '\n')
    else
      -- fallback to linewise if empty
      local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
      text_to_translate = table.concat(lines, '\n')
    end
  end

  return {
    bufnr = bufnr,
    mode = mode,
    srow = srow,
    scol = scol,
    erow = erow,
    ecol = ecol,
    text = text_to_translate,
  }
end

local function replace_visual_selection(selection, replacement)
  if selection.mode == 'V' then
    local new_lines = vim.split(replacement, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(selection.bufnr, selection.srow - 1, selection.erow, false, new_lines)
    return
  end

  local new_text = vim.split(replacement, '\n', { plain = true })
  vim.api.nvim_buf_set_text(
    selection.bufnr,
    selection.srow - 1,
    selection.scol,
    selection.erow - 1,
    selection.ecol + 1,
    new_text
  )
end

local function has_japanese(text)
  return text and text:find('[ぁ-んァ-ン一-龯]') ~= nil
end

local function translation_target_language(text)
  return has_japanese(text) and 'English' or 'Japanese'
end

local function translate_text(title, text_to_translate, source_kind)
  if not text_to_translate or vim.trim(text_to_translate) == '' then
    vim.notify('No translatable text found.', vim.log.levels.INFO)
    return
  end

  local target_language = translation_target_language(text_to_translate)
  local prompt = string.format([[
    Translate the following %s into %s.

    Return only the translated text.
    Do not include explanations, alternatives, quotes, code fences, prefixes, or suffixes.
    If the text is a single technical word, preserve the technical nuance and translate it naturally.

    Text:
    %s
  ]], source_kind or 'text', target_language, text_to_translate)

  local translated, err = ai.send_ai_request(prompt)
  if translated then
    show_in_split(title, translated)
  else
    show_in_split("AI Error", err or "Failed to get response from AI API")
  end
end

local function strip_comment_marker(line)
  local text = line or ''
  local commentstring = vim.bo.commentstring

  if commentstring and commentstring:find('%%s', 1, true) then
    local before, after = commentstring:match('^(.-)%%s(.-)$')
    before = vim.trim(before or '')
    after = vim.trim(after or '')

    if before ~= '' and vim.startswith(vim.trim(text), before) then
      text = vim.trim(text):sub(#before + 1)
      if after ~= '' and vim.endswith(vim.trim(text), after) then
        text = vim.trim(text):sub(1, #vim.trim(text) - #after)
      end
      return vim.trim(text)
    end
  end

  local patterns = {
    '^%s*//%s*(.*)$',
    '^%s*#%s*(.*)$',
    '^%s*%-%-%s*(.*)$',
    '^%s*/%*%s*(.-)%s*%*/%s*$',
    '^%s*%*%s*(.*)$',
  }

  for _, pattern in ipairs(patterns) do
    local stripped = text:match(pattern)
    if stripped then return vim.trim(stripped) end
  end

  return nil
end

local function get_current_comment_text()
  local line = vim.api.nvim_get_current_line()
  return strip_comment_marker(line)
end

local function translate_current_comment()
  local comment_text = get_current_comment_text()
  if not comment_text or comment_text == '' then
    vim.notify('Current line does not look like a comment.', vim.log.levels.INFO)
    return
  end

  translate_text('Translated Comment', comment_text, 'code comment')
end

local function translate_current_word()
  local word = vim.fn.expand('<cword>')
  if not word or word == '' then
    vim.notify('No word under cursor.', vim.log.levels.INFO)
    return
  end

  translate_text('Translated Word', word, 'word')
end

local function translate_visual_selection()
  local selection = get_visual_selection()
  local text_to_translate = selection.text

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

local function replace_visual_selection_with_translation()
  local selection = get_visual_selection()
  local text_to_translate = selection.text

  if not text_to_translate or text_to_translate == '' then
    print('No text selected.')
    return
  end

  local target_language = translation_target_language(text_to_translate)
  local prompt = string.format([[
    Translate the following text into %s.

    This result will be used to replace the selected text directly in an editor.
    Return only the translated word or sentence that corresponds to the selected text itself.
    Do not add explanations, notes, quotes, code fences, prefixes, suffixes, alternatives, or surrounding context.
    Preserve the original meaning as literally as possible while keeping the result natural in %s.

    If the text is ambiguous, not translatable, contains insufficient information, or you cannot safely return only the direct translation,
    output exactly this string and nothing else:
    %s

    Text:
    %s
  ]], target_language, target_language, REPLACE_TRANSLATION_FAILED, text_to_translate)

  local translated, err = ai.send_ai_request(prompt)
  if not translated then
    vim.notify(err or "Failed to get response from AI API", vim.log.levels.ERROR)
    return
  end

  translated = vim.trim(translated)
  if translated == '' or translated == REPLACE_TRANSLATION_FAILED then
    vim.notify("Translation replace stopped: text could not be translated safely.", vim.log.levels.WARN)
    return
  end

  replace_visual_selection(selection, translated)
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

local function translate_cursor_context()
  local bufnr = 0
  local lnum = vim.fn.line('.') - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

  if #diagnostics > 0 then
    translate_diagnostic_message()
    return
  end

  local comment_text = get_current_comment_text()
  if comment_text and comment_text ~= '' then
    translate_text('Translated Comment', comment_text, 'code comment')
    return
  end

  translate_current_word()
end

vim.keymap.set('n', '<leader>td', translate_diagnostic_message, { noremap = true, silent = true, desc = "translate: diag" })
vim.keymap.set('n', '<leader>tc', translate_current_comment, { noremap = true, silent = true, desc = "translate: comment" })
vim.keymap.set('n', '<leader>tt', translate_cursor_context, { noremap = true, silent = true, desc = "translate: cursor" })
vim.keymap.set('n', '<leader>tw', translate_current_word, { noremap = true, silent = true, desc = "translate: word" })
vim.keymap.set('x', '<leader>td', translate_visual_selection, { noremap = true, silent = true, desc = "translate: selection" })
vim.keymap.set('x', '<leader>tt', translate_visual_selection, { noremap = true, silent = true, desc = "translate: selection" })
vim.keymap.set('x', '<leader>tr', replace_visual_selection_with_translation, { noremap = true, silent = true, desc = "translate: replace" })
