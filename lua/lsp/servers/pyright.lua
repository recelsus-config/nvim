return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.cfg', 'setup.py', 'requirements.txt', '.git' },
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'basic',
        useLibraryCodeForTypes = true,
      },
    },
  },
}
