local M = {}

function M.load()
  local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
  local plugins = {}

  for _, fname in ipairs(vim.fn.readdir(plugin_dir)) do
    if fname:match('%.lua$') then
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
