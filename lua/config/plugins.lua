local M = {}

local function read_env()
  local env_path = vim.fn.stdpath('config') .. '/env'
  local env
  local file = io.open(env_path, 'r')
  if file then
    env = file:read('*l')
    file:close()
  end
  if not env or env == '' then
    env = os.getenv('NVIM_ENV') or 'minimal'
  end
  return env
end

local function should_include(fname, env)
  if env ~= 'minimal' then return true end
  local minimal_excludes = {
    ["nvim-lsp.lua"] = true,
    ["which-key.lua"] = true,
    ["telescope.lua"] = true,
    ["render-markdown.lua"] = true,
    ["markdown-preview.lua"] = true,
    ["copilot.lua"] = true,
    ["codecompanion.lua"] = true,
    ["lsp-signature.lua"] = true,
    ["cmp.lua"] = true,
  }
  return not minimal_excludes[fname]
end

function M.load()
  local env = read_env()
  local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
  local plugins = {}

  for _, fname in ipairs(vim.fn.readdir(plugin_dir)) do
    if fname:match('%.lua$') and should_include(fname, env) then
      local module_name = fname:gsub('%.lua$', ''):gsub('%.', '_')
      local ok, mod = pcall(require, 'plugins.' .. module_name)
      if ok then
        table.insert(plugins, mod)
      else
        vim.notify('Failed to load plugin: ' .. fname, vim.log.levels.WARN)
      end
    end
  end

  return plugins
end

return M

