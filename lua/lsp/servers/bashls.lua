return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      shellcheckPath = vim.fn.exepath('shellcheck'),
      shfmt = {
        path = vim.fn.exepath('shfmt'),
      },
    },
  },
}
