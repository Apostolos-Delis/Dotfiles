-- Autocommands
-- Migrated from init.vim autocmds

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Filetype-specific settings
local filetype_group = augroup("FileTypeSettings", { clear = true })

-- Python
autocmd("FileType", {
  group = filetype_group,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
    vim.opt_local.textwidth = 119
    vim.opt_local.fileformat = "unix"
  end,
})

-- JavaScript/TypeScript
autocmd("FileType", {
  group = filetype_group,
  pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact", "tsx", "jsx" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Ruby
autocmd("FileType", {
  group = filetype_group,
  pattern = "ruby",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
  end,
})

-- HTML/CSS/XML
autocmd("FileType", {
  group = filetype_group,
  pattern = { "html", "css", "xml", "json", "yaml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Markdown
autocmd("FileType", {
  group = filetype_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 89
    vim.opt_local.autoindent = true
    vim.opt_local.expandtab = true
  end,
})

-- LaTeX
autocmd("FileType", {
  group = filetype_group,
  pattern = { "tex", "latex" },
  callback = function()
    vim.opt_local.textwidth = 89
    vim.opt_local.autoindent = true
    vim.opt_local.expandtab = true
  end,
})

-- Lua
autocmd("FileType", {
  group = filetype_group,
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Terminal mode
local terminal_group = augroup("TerminalSettings", { clear = true })

autocmd("TermOpen", {
  group = terminal_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

autocmd("BufEnter", {
  group = terminal_group,
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Highlight yanked text
local highlight_group = augroup("HighlightYank", { clear = true })

autocmd("TextYankPost", {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Return to last edit position when opening files
local last_position_group = augroup("LastPosition", { clear = true })

autocmd("BufReadPost", {
  group = last_position_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when window is resized
local resize_group = augroup("ResizeSplits", { clear = true })

autocmd("VimResized", {
  group = resize_group,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Close certain filetypes with 'q'
local close_with_q_group = augroup("CloseWithQ", { clear = true })

autocmd("FileType", {
  group = close_with_q_group,
  pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
