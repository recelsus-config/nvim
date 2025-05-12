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

local function translate_diagnostic_message()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  if #diagnostics == 0 then
    print("No diagnostics available at the current cursor position.")
    return
  end

  local message = diagnostics[1].message
  local api_key = vim.fn.getenv("GEMINI_API_KEY")

  if not api_key or api_key == "" then
    print("GEMINI_API_KEY is not set.")
    return
  end

  local prompt = string.format("Translate the following LSP diagnostic message into Japanese:\n\n%s", message)

  local body = vim.fn.json_encode({
    contents = {
      {
        parts = {
          { text = prompt }
        }
      }
    }
  })

  local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. api_key
  local curl_cmd = {
    "curl", "-s", "-X", "POST", url,
    "-H", "Content-Type: application/json",
    "-d", body,
  }

  local response = vim.fn.system(curl_cmd)

  local ok, parsed = pcall(vim.fn.json_decode, response)
  if not ok or not parsed or not parsed.candidates then
    print("Failed to get response from Gemini.")
    return
  end

  local translated = parsed.candidates[1].content.parts[1].text
  print("[Translated Diagnostic]: " .. translated)
end

vim.keymap.set('n', '<leader>td', translate_diagnostic_message, { noremap = true, silent = true, desc = "[LSP] Translate Diagnostic Message" })

function YankLastCommandOutput()

  if vim.bo.buftype ~= "terminal" then
    print("This is not a terminal buffer!")
    return
  end

  local prompt_pattern = "%[.*@.*% .*(.*) NL%]%$.*$"

  local last_line_num = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, last_line_num, false)

  local start_line = nil
  local end_line = nil

  for i = last_line_num, 1, -1 do
    if lines[i]:match(prompt_pattern) then
      if not end_line then

        end_line = i
      elseif not start_line then

        start_line = i + 1
        break
      end
    end
  end

  if start_line and end_line then

    local yank_start = start_line
    local yank_end = end_line - 1

    if yank_start <= yank_end then
      vim.cmd(string.format("%d,%dyank", yank_start, yank_end))
      print("Yanked lines from last command output!")
    else
      print("No command output to yank!")
    end
  else
    print("Could not find two prompt patterns!")
  end
end

vim.api.nvim_set_keymap('n', '<C-y>', ':lua YankLastCommandOutput()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-y>', [[<C-\><C-n>:lua YankLastCommandOutput()<CR>]], { noremap = true, silent = true })
