local function run_shell_command(cmd)
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 and vim.tbl_isempty(output) then
    vim.notify(
      string.format("shell command failed (%d): %s", exit_code, cmd),
      vim.log.levels.ERROR
    )
    return nil
  end

  if exit_code ~= 0 then
    vim.notify(
      string.format("shell command exited with %d: %s", exit_code, cmd),
      vim.log.levels.WARN
    )
  end

  return output
end

local function insert_output_below(line_nr, lines)
  if not lines or vim.tbl_isempty(lines) then
    vim.notify("shell command returned no output", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, lines)
end

local function shell_insert(cmd, line_nr)
  if not cmd or vim.trim(cmd) == "" then
    vim.notify("shell command is empty", vim.log.levels.WARN)
    return
  end

  local output = run_shell_command(cmd)
  if output == nil then
    return
  end

  insert_output_below(line_nr, output)
end

vim.api.nvim_create_user_command("ShellInsert", function(opts)
  local line_nr = opts.range > 0 and opts.line2 or vim.fn.line(".")
  shell_insert(opts.args, line_nr)
end, {
  desc = "Insert shell command output below cursor or range",
  nargs = 1,
  range = true,
  complete = "shellcmd",
})

vim.keymap.set("n", "<leader>si", function()
  vim.ui.input({ prompt = "Shell command: " }, function(input)
    if input == nil then
      return
    end

    shell_insert(input, vim.fn.line("."))
  end)
end, { noremap = true, silent = true, desc = "shell: insert output" })

