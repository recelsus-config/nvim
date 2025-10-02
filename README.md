# Dependencies

`fzf` `ripgrep` `nodejs` `npm` `cmake` `make`

Language servers are installed via Mason. Common servers used here:
- TypeScript: `typescript-language-server` (ts_ls)
- C/C++: `clangd`
- Bash: `bash-language-server`
- Lua: `lua-language-server`

# Keymap List

### Tab Related Operations
- `<leader>1`: Go to the 1st tab
- `<leader>2`: Go to the 2nd tab
- `<leader>3`: Go to the 3rd tab
- `<leader>4`: Go to the 4th tab
- `<leader>t`: Open a new tab (`:tabnew<CR>`)
- `<leader>q`: Close the current tab (`:tabclose<CR>`)

### LSP Related Operations
- `<space>e`: Show diagnostics for the current cursor position in a popup
- `[d`: Go to the previous diagnostic message
- `]d`: Go to the next diagnostic message
- `K`: Show documentation for the symbol under the cursor (`hover`)
- `gd`: Jump to the definition of the symbol under the cursor (`goto definition`)
- `gi`: Jump to the implementation of the symbol under the cursor (`goto implementation`)
- `gr`: Find references of the symbol under the cursor (`goto references`)
- `gs`: Show signature help for the symbol under the cursor (`signature help`)
- `<leader>ih`: Toggle inlay hints (if supported by the server)
- `<leader>lr`: Rename symbol
- `<leader>la`: Code action
- `<leader>lf`: Format buffer

### cmp Completion Related Operations
- `<C-d>`: Scroll documentation up (4 lines)
- `<C-f>`: Scroll documentation down (4 lines)
- `<C-s>`: Start completion
- `<C-e>`: Close completion window
- `<CR>`: Select and confirm completion candidate
- `<C-n>`: Go to the next completion candidate
- `<C-p>`: Go to the previous completion candidate

### hlslens Related Operations
- `n`: Move to the next search result and display `hlslens` highlights
- `N`: Move to the previous search result and display `hlslens` highlights
- `*`: Search for the word under the current cursor and display `hlslens` highlights
- `#`: Search for the word under the current cursor in reverse and display `hlslens` highlights
- `g*`: Search for partially matching words and display `hlslens` highlights
- `g#`: Search for partially matching words in reverse and display `hlslens` highlights

### Telescope Related Operations
- `<leader>ff`: Find files (`Telescope find_files`)
- `<leader>fg`: Search text (`Telescope live_grep`)
- `<leader>fb`: Show buffer list (`Telescope buffers`)
- `<leader>fh`: Search help tags (`Telescope help_tags`)
- `<leader>fk`: Show keymap list (`builtin.keymaps`)

## Configuration Structure

- Plugin manager: `lazy.nvim` (`init.lua`)
- Global editor settings & diagnostics: `lua/config/config.lua`
- LSP core (Mason + native LSP + LspAttach mappings): `lua/plugins/nvim-lsp.lua`
- Completion (cmp) setup: `lua/plugins/cmp.lua`
- Copilot integration: `lua/plugins/copilot.lua`
- Per-language LSP overrides: `lua/lsp/servers/*.lua`

### LSP Behavior (Neovim 0.11 style)
- LSP servers are installed with Mason and started via Neovim's native API (`vim.lsp.config` + `vim.lsp.start`).
- Buffer-local keymaps and `omnifunc` are set on `LspAttach`.
- Inlay hints are enabled by default when supported and can be toggled via `<leader>ih`.
- Global diagnostics UI is configured once in `lua/config/config.lua`.

### Per-language LSP Overrides
Place a file under `lua/lsp/servers/<server>.lua` that returns a table merged over the built-in defaults before `vim.lsp.start`.

Provided examples:
- TypeScript (ts_ls): `lua/lsp/servers/ts_ls.lua`
- C/C++ (clangd): `lua/lsp/servers/clangd.lua`
- Bash (bashls): `lua/lsp/servers/bashls.lua`
- Lua (lua_ls): `lua/lsp/servers/lua_ls.lua`

Note: If your environment reports the server name `tsserver`, it is mapped to `ts_ls` by the loader.

### Completion (cmp)
- Lives in `lua/plugins/cmp.lua` and is independent from the LSP plugin.
- Sources enabled: `nvim_lsp`, `nvim_lsp_document_symbol`, `nvim_lsp_signature_help`, `copilot`, `buffer`, `path`.
- Copilot completion is wired via `copilot-cmp` (see `lua/plugins/copilot.lua`).

## Extra Utilities

- Yank diagnostics and code lines:
  - `<leader>yd`: Yank current line + topmost diagnostic under cursor
  - `<leader>yad`: Yank entire buffer, then list lines with diagnostics
  - `<leader>ys` (visual): Yank selected block, then list diagnostics in selection
  - Implementations: `lua/config/yank.lua`
- Translate diagnostics or visual selection (requires external provider if configured):
  - `<leader>td` (normal/visual)
  - Implementation: `lua/config/translate.lua`

## Notes

- Local environment selector file `env` (at repo root) is ignored by VCS and read by `init.lua` if present.
- `lazy-lock.json` is ignored (not tracked). If you want to pin plugin versions, remove it from `.gitignore` locally.
