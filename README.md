# Dependencies

`fzf` `ripgrep` `nodejs` `npm` `cmake` `make`

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

### cmp Completion Related Operations
- `<C-d>`: Scroll documentation up (4 lines)
- `<C-f>`: Scroll documentation down (4 lines)
- `<C-s>`: Start completion
- `<C-e>`: Close completion window
- `<CR>`: Select and confirm completion candidate
- `<C-j>`: Go to the next completion candidate
- `<C-k>`: Go to the previous completion candidate

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

