local M = {}

local BEGIN_MARK = 'copilot: style hint begin'
local END_MARK = 'copilot: style hint end'

local function comment(line)
  local cs = vim.bo.commentstring
  if not cs or cs == '' then cs = '# %s' end
  if not cs:find('%%s') then
    cs = (cs .. ' %s')
  end
  return cs:gsub('%%s', line)
end

local function find_block_at_cursor(bufnr, row)
  local total = vim.api.nvim_buf_line_count(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, total, false)
  local sidx
  for i = row, 1, -1 do
    if lines[i] and lines[i]:find(BEGIN_MARK, 1, true) then
      sidx = i
      break
    end
  end
  if not sidx then return nil end
  local eidx
  for i = row, total do
    if lines[i] and lines[i]:find(END_MARK, 1, true) then
      eidx = i
      break
    end
  end
  if eidx and sidx <= row and row <= eidx then
    return sidx, eidx
  end
  return nil
end

function M.toggle_snake_case_hint()
  local bufnr = 0
  local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
  local sidx, eidx = find_block_at_cursor(bufnr, row)
  if sidx and eidx then
    vim.api.nvim_buf_set_lines(bufnr, sidx - 1, eidx, false, {})
    print('Removed Copilot hint at cursor')
    return
  end

  local block = {
    comment(BEGIN_MARK),
    comment('Please prefer snake_case identifiers instead of camelCase.'),
    comment('Use underscore_separated_names for variables and functions.'),
    comment(END_MARK),
  }
  vim.api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, block)
  print('Inserted Copilot style hint at cursor')
end

return M
