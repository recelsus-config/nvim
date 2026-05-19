return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithSnippetText = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsWithSnippetText = true,
      },
    },
  },
}
