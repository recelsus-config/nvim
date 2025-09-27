local M = {}

function M.send_ai_request(prompt)
  local api_key = vim.fn.getenv("GEMINI_API_KEY")
  if not api_key or api_key == "" then
    return nil, "GEMINI_API_KEY is not set."
  end

  local body = vim.fn.json_encode({
    contents = {
      {
        parts = {
          { text = prompt }
        }
      }
    }
  })

  local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" .. api_key
  local curl_cmd = {
    "curl", "-sS", "-X", "POST", url,
    "-H", "Content-Type: application/json",
    "-d", body,
  }

  local response = vim.fn.system(curl_cmd)
  local exit_code = vim.v.shell_error
  if exit_code ~= 0 then
    return nil, string.format("curl failed with exit code %d", exit_code)
  end

  local ok, parsed = pcall(vim.fn.json_decode, response)
  if not ok or not parsed then
    return nil, "Failed to decode AI response"
  end
  if parsed.error then
    local msg = parsed.error.message or "AI API returned an error"
    return nil, msg
  end
  if not parsed.candidates or not parsed.candidates[1]
     or not parsed.candidates[1].content
     or not parsed.candidates[1].content.parts
     or not parsed.candidates[1].content.parts[1]
     or not parsed.candidates[1].content.parts[1].text then
    return nil, "AI response missing content"
  end

  return parsed.candidates[1].content.parts[1].text, nil
end

return M
