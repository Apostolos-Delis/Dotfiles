-- Core Neovim options
-- Migrated from init.vim settings

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation (defaults, filetypes can override)
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.smarttab = true
opt.cindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.wrapscan = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = false
opt.wrap = true
opt.breakindent = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.ruler = true
opt.laststatus = 2
opt.cmdheight = 1
opt.showmatch = true
opt.matchtime = 1

-- Behavior
opt.hidden = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undodir = vim.fn.expand("~/.tmp/undo")
opt.swapfile = false
opt.backup = false
opt.updatetime = 100
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.lazyredraw = true
opt.history = 2000

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Whitespace characters (for :set list)
opt.list = true
opt.listchars = {
  tab = "»·",
  eol = "↲",
  nbsp = "␣",
  trail = "·",
  extends = "→",
  precedes = "←",
}

-- Grep (use ripgrep)
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Title
opt.title = true

-- Python provider
vim.g.python3_host_prog = "/usr/local/bin/python3"

-- Disable netrw (we use oil.nvim or nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Ensure undo directory exists
vim.fn.mkdir(vim.fn.expand("~/.tmp/undo"), "p")
