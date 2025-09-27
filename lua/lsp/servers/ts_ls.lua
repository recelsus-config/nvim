return {
  -- typescript-language-server (ts_ls)
  -- If your environment still uses 'tsserver' name, lsp/init.lua maps it.
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

