local function show_message_in_split(msg)
  vim.cmd("botright 10split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(msg, "\n"))
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_set_option(buf, 'filetype', 'log')
end

vim.api.nvim_create_user_command("ShowMessage", function()
  local output = vim.api.nvim_exec("messages", true)
  show_message_in_split(output)
end, {})

vim.keymap.set('n', '<Leader>ms', ':ShowMessage<CR>', { noremap = true, silent = true, desc = "Show :messages in split" })

