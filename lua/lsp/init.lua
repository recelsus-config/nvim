local M = {}

function M.configs()
  local configs = {}
  local seen = {}

  for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/lsp/servers/*.lua', true)) do
    local name = path:match('([^/]+)%.lua$')
    if name and not seen[name] then
      seen[name] = true
      local ok, config = pcall(require, 'lsp.servers.' .. name)
      if ok and type(config) == 'table' then
        table.insert(configs, { name = name, config = config })
      end
    end
  end

  table.sort(configs, function(left, right)
    return left.name < right.name
  end)

  return configs
end

return M
