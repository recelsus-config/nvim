local function paste_with(command)
  return function()
    local output = vim.fn.systemlist(command)
    return { output, 'v' }
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
  paste = function()
    return { {}, 'v' }
  end
end

vim.g.clipboard = {
  name = 'OSC52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste,
  },
  cache_enabled = 0,
}
