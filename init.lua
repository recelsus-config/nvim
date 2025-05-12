vim.g.mapleader = ' '

require('config.config')
require('config.command')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function load_plugins()
  local env_path = vim.fn.stdpath("config") .. "/env"
  local env = nil

  local file = io.open(env_path, "r")
  if file then
    env = file:read("*l")
    file:close()
  end

  if not env or env == "" then
    env = os.getenv("NVIM_ENV") or "minimal"
  end

  local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
  local plugins = {}

  local minimal_excludes = {
    ["nvim-lsp.lua"] = true,
    ["which-key.lua"] = true,
    ["telescope.lua"] = true,
    ["render-markdown.lua"] = true,
    ["markdown-preview.lua"] = true,
    ["copilot.lua"] = true,
    ["codecompanion.lua"] = true,
    ["lsp-signature.lua"] = true,
  }

  for _, fname in ipairs(vim.fn.readdir(plugin_dir)) do
    if fname:match("%.lua$") then
      if env == "minimal" and minimal_excludes[fname] then
        goto continue
      end

      local module_name = fname
        :gsub("%.lua$", "")
        :gsub("%.", "_")

      local ok, mod = pcall(require, "plugins." .. module_name)
      if ok then
        table.insert(plugins, mod)
      else
        vim.notify("Failed to load plugin: " .. fname, vim.log.levels.WARN)
      end
    end
    ::continue::
  end

  return plugins
end

require("lazy").setup(load_plugins(), {
  rocks = { enabled = false },
})

