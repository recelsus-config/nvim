local M = {}

-- Returns a table of options for a given server name if defined under lsp/servers/<name>.lua
-- Example file should return an options table that will be merged into lspconfig setup opts.
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

return M

