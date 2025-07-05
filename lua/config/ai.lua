local M = {}

function M.send_ai_request(prompt)
  local api_key = vim.fn.getenv("GEMINI_API_KEY")
  if not api_key or api_key == "" then
    print("GEMINI_API_KEY is not set.")
    return nil
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
    "curl", "-s", "-X", "POST", url,
    "-H", "Content-Type: application/json",
    "-d", body,
  }

  local response = vim.fn.system(curl_cmd)
  local ok, parsed = pcall(vim.fn.json_decode, response)

  if not ok or not parsed or not parsed.candidates then
    print("Failed to get response from AI API.")
    return nil
  end

  return parsed.candidates[1].content.parts[1].text
end

return M

