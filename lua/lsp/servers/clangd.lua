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
}

