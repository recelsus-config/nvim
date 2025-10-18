local env_var = "NVIM_LOG_FILE"

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function null_path()
  return is_windows() and "NUL" or "/dev/null"
end

local function state_path()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "log")
end

local function disable_logging()
  vim.fn.setenv(env_var, null_path())
  vim.g.nvim_log_enabled = false
end

local function enable_logging()
  vim.fn.setenv(env_var, state_path())
  vim.g.nvim_log_enabled = true
end

if vim.g.nvim_log_enabled == nil then
  disable_logging()
end

vim.api.nvim_create_user_command("NvimLogDisable", function()
  disable_logging()
  vim.notify("Neovim logging disabled", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("NvimLogEnable", function()
  enable_logging()
  vim.notify("Neovim logging enabled at " .. vim.fn.getenv(env_var), vim.log.levels.INFO)
end, {})

