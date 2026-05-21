local cached_registers = {
  ['+'] = nil,
  ['*'] = nil,
}

local function copy_with_cache(reg)
  local osc52_copy = require('vim.ui.clipboard.osc52').copy(reg)

  return function(lines, regtype)
    cached_registers[reg] = {
      lines = vim.deepcopy(lines),
      regtype = regtype,
    }

    osc52_copy(lines)
  end
end

local function cached_paste(reg)
  return function()
    local cached = cached_registers[reg]

    if cached == nil then
      return {}
    end

    return { vim.deepcopy(cached.lines), cached.regtype }
  end
end

local function paste_with(command)
  return function()
    local output = vim.fn.system(command)

    if vim.v.shell_error ~= 0 then
      return {}
    end

    local is_linewise = output:sub(-1) == "\n"
    local lines = vim.split(output:gsub("\r\n", "\n"):gsub("\r", "\n"), "\n", { plain = true })

    if is_linewise then
      table.remove(lines)
    end

    return { lines, is_linewise and 'V' or 'v' }
  end
end

local paste
if vim.fn.executable('pbpaste') == 1 then
  paste = paste_with('pbpaste')
elseif vim.fn.executable('wl-paste') == 1 then
  paste = paste_with('wl-paste --no-newline')
elseif vim.fn.executable('xclip') == 1 then
  paste = paste_with('xclip -selection clipboard -out')
else
  paste = nil
end

vim.g.clipboard = {
  name = 'OSC52',
  copy = {
    ['+'] = copy_with_cache('+'),
    ['*'] = copy_with_cache('*'),
  },
  paste = {
    ['+'] = paste or cached_paste('+'),
    ['*'] = paste or cached_paste('*'),
  },
  cache_enabled = 0,
}
