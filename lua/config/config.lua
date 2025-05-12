local opt = vim.opt
local cmd = vim.cmd

opt.title = true
opt.encoding = 'utf-8'
vim.scriptencoding = 'utf-8'
opt.fileformats = 'unix', 'mac'
opt.mouse = "a"

opt.ambiwidth = "double"
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.number = true
opt.errorbells = false
opt.cursorline = true

opt.showtabline = 2
opt.cmdheight = 2

opt.writebackup = false
opt.backup = false
opt.wrap = false
opt.matchtime = 0

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.wrapscan = true

opt.showcmd = true
opt.wildmenu = true
opt.clipboard:append('unnamedplus')

opt.ttimeout = true
opt.ttimeoutlen = 50

opt.undofile = true
opt.undodir = vim.fn.stdpath('cache') .. '/undo'
opt.swapfile = false

opt.nrformats = ''
opt.whichwrap = 'h,l,<,>,[,],~'
opt.virtualedit = 'block'

opt.signcolumn = 'yes'

opt.splitbelow = true
opt.splitright = true

opt.syntax = enable

opt.timeoutlen = 600

vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.opt.termguicolors = true

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

