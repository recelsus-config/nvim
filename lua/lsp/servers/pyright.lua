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

local function detect_venv_roots(python_path)
  if not python_path then return end
  local dir = vim.fs.dirname(python_path)
  if not dir then return end

  local tail = vim.fs.basename(dir)
  if tail ~= "bin" and tail ~= "Scripts" then return end

  local venv_root = vim.fs.dirname(dir)
  if not venv_root or venv_root == "" then return end

  return venv_root, vim.fs.basename(venv_root)
end

local function find_site_packages(venv_root)
  if not venv_root or venv_root == "" then return end

  local candidates = {}
  if is_win() then
    table.insert(candidates, vim.fs.joinpath(venv_root, "Lib", "site-packages"))
  else
    local lib_dir = vim.fs.joinpath(venv_root, "lib")
    local handle = uv.fs_scandir(lib_dir)
    if handle then
      while true do
        local name = uv.fs_scandir_next(handle)
        if not name then break end
        if name:match("^python%f[%.%d]") then
          table.insert(candidates, vim.fs.joinpath(lib_dir, name, "site-packages"))
        end
      end
    end
  end

  for _, path in ipairs(candidates) do
    local stat = uv.fs_stat(path)
    if stat and stat.type == "directory" then
      return path
    end
  end
end

local function apply_environment(config, root_dir)
  root_dir = root_dir or config.root_dir or vim.fn.getcwd()

  local python_path = detect_python(root_dir)
  if not python_path then return end

  local venv_root, venv_name = detect_venv_roots(python_path)
  local site_packages = find_site_packages(venv_root)

  config.settings = config.settings or {}
  config.settings.python = config.settings.python or {}
  local python_settings = config.settings.python

  if not python_settings.defaultInterpreterPath then
    python_settings.defaultInterpreterPath = python_path
  end

  if not python_settings.pythonPath then
    python_settings.pythonPath = python_path
  end

  if venv_root and venv_name then
    python_settings.venvPath = vim.fs.dirname(venv_root)
    python_settings.venv = venv_name
  elseif root_dir and root_dir ~= "" then
    python_settings.venvPath = root_dir
    python_settings.venv = ".venv"
  end

  local analysis = python_settings.analysis or {}
  analysis.extraPaths = analysis.extraPaths or {}
  local extra_paths = analysis.extraPaths

  local function add_path(list, path)
    if not path or path == "" then return end
    for _, existing in ipairs(list) do
      if existing == path then return end
    end
    table.insert(list, path)
  end

  add_path(extra_paths, site_packages)
  if root_dir and root_dir ~= "" then
    add_path(extra_paths, vim.fs.joinpath(root_dir, "src"))
  end

  python_settings.analysis = analysis

  if not config.cmd_env then config.cmd_env = {} end
  if venv_root then
    config.cmd_env.VIRTUAL_ENV = venv_root
  end

  local path_sep = is_win() and ';' or ':'
  local paths = {}
  if site_packages then table.insert(paths, site_packages) end
  if root_dir and root_dir ~= "" then table.insert(paths, vim.fs.joinpath(root_dir, "src")) end

  if #paths > 0 then
    local joined = table.concat(paths, path_sep)
    if config.cmd_env.PYTHONPATH and config.cmd_env.PYTHONPATH ~= "" then
      config.cmd_env.PYTHONPATH = config.cmd_env.PYTHONPATH .. path_sep .. joined
    else
      config.cmd_env.PYTHONPATH = joined
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

function M.before_init(_, config)
  apply_environment(config, config.root_dir)
end

function M.on_new_config(config, root_dir)
  apply_environment(config, root_dir)
end

return M
