return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--completion-style=bundled',
    '--fallback-style=LLVM',
    -- You can uncomment the next line if you experience offset issues.
    -- '--offset-encoding=utf-16',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
}
