local M = {}

local function get_comment_fmt()
  local cs = vim.bo.commentstring
  if not cs or cs == '' then
    cs = '# %s'
  elseif not cs:find('%%s') then
    cs = cs .. ' %s'
  end
  return cs
end

local function comment_line(text)
  local fmt = get_comment_fmt()
  return string.format(fmt, text)
end

local function clamp(n, minv, maxv)
  if n < minv then return minv end
  if n > maxv then return maxv end
  return n
end

local function build_box(lines)
  local BAR_LEN = 10
  local bar = string.rep('=', BAR_LEN)

  local out = {}
  table.insert(out, comment_line(bar))
  for _, l in ipairs(lines) do
    table.insert(out, comment_line(l))
  end
  table.insert(out, comment_line(bar))
  return out
end

local function get_visual_line_range()
  local bufnr = 0
  local srow = vim.fn.getpos("'<")[2]
  local erow = vim.fn.getpos("'>")[2]
  if srow > erow then srow, erow = erow, srow end
  return bufnr, srow, erow
end

function M.comment_box_visual()
  local bufnr, srow, erow = get_visual_line_range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
  if #lines == 0 then return end
  local box = build_box(lines)
  vim.api.nvim_buf_set_lines(bufnr, srow - 1, erow, false, box)
end

function M.comment_box_current_line()
  local bufnr = 0
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
  local box = build_box({ line })
  vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, box)
end

-- Keymaps
vim.keymap.set('n', '<leader>cb', M.comment_box_current_line, { noremap = true, silent = true, desc = 'comment: box' })
vim.keymap.set('v', '<leader>cb', M.comment_box_visual,       { noremap = true, silent = true, desc = 'comment: box' })

return M
