local M = {}

local startup_cwd = vim.fn.getcwd()
local config_env_path = vim.fs.joinpath(vim.fn.stdpath("config"), ".env")

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function decode_double_quoted(value)
  return value:gsub("\\(.)", {
    n = "\n",
    r = "\r",
    t = "\t",
    ['"'] = '"',
    ["\\"] = "\\",
  })
end

local function parse_value(raw)
  local value = trim(raw)
  if value == "" then return "" end

  local first = value:sub(1, 1)
  if first == "'" then
    local last = value:find("'", 2, true)
    return last and value:sub(2, last - 1) or value:sub(2)
  end

  if first == '"' then
    local escaped = false
    for i = 2, #value do
      local char = value:sub(i, i)
      if char == '"' and not escaped then
        return decode_double_quoted(value:sub(2, i - 1))
      end
      escaped = char == "\\" and not escaped
    end
    return decode_double_quoted(value:sub(2))
  end

  return trim(value:gsub("%s+#.*$", ""))
end

local function parse_line(line)
  local text = trim(line)
  if text == "" or text:sub(1, 1) == "#" then return end

  text = text:gsub("^export%s+", "")

  local key, raw_value = text:match("^([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.*)$")
  if not key then return nil, "invalid .env line: " .. line end

  return key, parse_value(raw_value)
end

local function is_file(path)
  local stat = path and vim.uv.fs_stat(path)
  return stat and stat.type == "file"
end

local function resolve_path(path, base_dir)
  if not path or path == "" then return nil end

  if vim.fs.normalize(path):sub(1, 1) == "/" then
    return vim.fs.normalize(path)
  end

  return vim.fs.normalize(vim.fs.joinpath(base_dir or vim.fn.getcwd(), path))
end

function M.find_project_env()
  return vim.fs.find(".env", {
    path = startup_cwd,
    upward = true,
    type = "file",
  })[1]
end

function M.load(path, opts)
  opts = opts or {}
  local resolved = resolve_path(path, opts.base_dir)
  if not resolved or not is_file(resolved) then
    if not opts.silent then
      vim.notify("Env file not found: " .. (resolved or path or ".env"), vim.log.levels.WARN)
    end
    return false
  end

  local lines = vim.fn.readfile(resolved)
  local count = 0
  local errors = {}

  for line_number, line in ipairs(lines) do
    local key, value_or_error = parse_line(line)
    if key then
      vim.fn.setenv(key, value_or_error)
      count = count + 1
    elseif value_or_error then
      table.insert(errors, string.format("%s:%d: %s", resolved, line_number, value_or_error))
    end
  end

  if not opts.silent then
    local message = string.format("Loaded %d env vars from %s", count, resolved)
    if #errors > 0 then
      message = message .. string.format(" (%d skipped)", #errors)
    end
    vim.notify(message, #errors > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
  end

  return true, count, errors
end

function M.load_project(path)
  local target = path and path ~= "" and path or M.find_project_env()
  return M.load(target, { base_dir = startup_cwd })
end

if is_file(config_env_path) then
  M.load(config_env_path, { silent = true })
end

vim.api.nvim_create_user_command("EnvLoad", function(opts)
  M.load_project(opts.args)
end, {
  nargs = "?",
  complete = "file",
  desc = "Load an env file manually. Without an argument, search .env upward from startup cwd.",
})

return M
