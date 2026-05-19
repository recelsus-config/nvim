local M = {}

-- Returns a full server config from lsp/servers/<name>.lua.
function M.get(server_name)
  local try = function(name)
    local ok, mod = pcall(require, 'lsp.servers.' .. name)
    if ok and type(mod) == 'table' then return mod end
  end
  -- try exact name
  local mod = try(server_name)
  if mod then return mod end
  -- tsserver vs ts_ls compatibility
  if server_name == 'tsserver' then
    return try('ts_ls')
  elseif server_name == 'ts_ls' then
    return try('tsserver')
  end
end

function M.names()
  local names = {}
  local seen = {}

  for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/lsp/servers/*.lua', true)) do
    local name = path:match('([^/]+)%.lua$')
    if name and not seen[name] then
      seen[name] = true
      table.insert(names, name)
    end
  end

  table.sort(names)
  return names
end

return M
