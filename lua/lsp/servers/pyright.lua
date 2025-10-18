local uv = vim.uv or vim.loop
local unpack = table.unpack or unpack

local function is_win()
  local uname = uv.os_uname()
  return uname.sysname == "Windows_NT"
end

local function python_candidates(root_dir)
  local join = vim.fs.joinpath
  local exe = is_win() and "python.exe" or "python"
  local bins = is_win() and { "Scripts", exe } or { "bin", exe }
  local paths = {}

  if root_dir and root_dir ~= "" then
    table.insert(paths, join(root_dir, ".venv", unpack(bins)))
    table.insert(paths, join(root_dir, "venv", unpack(bins)))
  end

  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    table.insert(paths, join(vim.env.VIRTUAL_ENV, unpack(bins)))
  end

  return paths
end

local function detect_python(root_dir)
  for _, path in ipairs(python_candidates(root_dir)) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
end

local M = {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
}

function M.on_new_config(config, root_dir)
  local python_path = detect_python(root_dir)
  if not python_path then return end

  config.settings = config.settings or {}
  config.settings.python = config.settings.python or {}

  if not config.settings.python.pythonPath then
    config.settings.python.pythonPath = python_path
  end

  if root_dir and root_dir ~= "" then
    config.settings.python.venvPath = root_dir
    config.settings.python.venv = ".venv"
  end
end

return M
