-- Key mappings
-- Migrated from init.vim keymaps

local map = vim.keymap.set

-- Navigation (wrapped lines)
map({ "n", "v" }, "j", "gj", { desc = "Move down (wrapped)" })
map({ "n", "v" }, "k", "gk", { desc = "Move up (wrapped)" })

-- Buffer navigation (auto-save before switching)
map("n", "<Tab>", "<cmd>update<cr><cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>update<cr><cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Toggle search highlight
map("n", "<space>", "<cmd>set hlsearch!<cr>", { desc = "Toggle search highlight" })

-- Yank to end of line (more intuitive like D and C)
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Repeat last command in visual mode
map("v", ".", ":normal .<cr>", { desc = "Repeat last command" })

-- Search word under cursor in symbols (replaces old Q :Tags)
map("n", "Q", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Search symbols" })

-- Expand file path under cursor
map("n", "<C-E>", "<cmd>vertical wincmd f<cr>", { desc = "Open file under cursor in vsplit" })

-- =============================================================================
-- CONFIG FILE SHORTCUTS (all your ,e* mappings)
-- =============================================================================
map("n", "<leader>ei", "<cmd>edit ~/.config/nvim/init.lua<cr>", { desc = "Edit init.lua" })
map("n", "<leader>eo", "<cmd>edit ~/.config/nvim/lua/config/options.lua<cr>", { desc = "Edit options.lua" })
map("n", "<leader>ek", "<cmd>edit ~/.config/nvim/lua/config/keymaps.lua<cr>", { desc = "Edit keymaps.lua" })
map("n", "<leader>ev", "<cmd>edit ~/.vimrc<cr>", { desc = "Edit .vimrc" })
map("n", "<leader>ez", "<cmd>edit ~/.zshrc<cr>", { desc = "Edit .zshrc" })
map("n", "<leader>et", "<cmd>edit ~/.tmux.conf<cr>", { desc = "Edit .tmux.conf" })
map("n", "<leader>ea", "<cmd>edit ~/.aliases<cr>", { desc = "Edit .aliases" })
map("n", "<leader>eg", "<cmd>edit ~/.gitconfig<cr>", { desc = "Edit .gitconfig" })
map("n", "<leader>eb", "<cmd>edit ~/.bashrc<cr>", { desc = "Edit .bashrc" })
map("n", "<leader>ep", "<cmd>edit ~/.p10k.zsh<cr>", { desc = "Edit p10k config" })
map("n", "<leader>en", "<cmd>edit ~/Documents/notes<cr>", { desc = "Edit notes" })

-- =============================================================================
-- TOGGLES (all your ,t* mappings)
-- =============================================================================
map("n", "<leader>ts", "<cmd>set list!<cr>", { desc = "Toggle whitespace" })
map("n", "<leader>tb", "<C-^>", { desc = "Toggle last buffer" })
map("n", "<leader>ti", "<cmd>IBLToggle<cr>", { desc = "Toggle indent lines" })
map("n", "<leader>ta", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- =============================================================================
-- SPELL CHECK
-- =============================================================================
map("n", "<leader>sp", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })
map("i", "<C-T>", "<c-g>u<Esc>[s1z=`]a<c-g>u", { desc = "Fix previous spelling error" })

-- =============================================================================
-- CLEANUP
-- =============================================================================
map("n", "<leader>dw", [[<cmd>%s/\s\+$//e<cr><cmd>noh<cr>]], { desc = "Remove trailing whitespace" })
map("n", "<leader>ds", [[<cmd>%s#\($\n\s*\)\+\%$##e<cr><cmd>noh<cr>]], { desc = "Remove trailing blank lines" })

-- =============================================================================
-- WINDOW/BUFFER MANAGEMENT
-- =============================================================================
map("n", "<leader>wv", "<cmd>vnew<cr>", { desc = "Vertical split (new)" })
map("n", "<leader>ws", "<cmd>new<cr>", { desc = "Horizontal split (new)" })
map("n", "<leader>bd", "<cmd>bdelete!<cr>", { desc = "Delete buffer" })

-- =============================================================================
-- REFACTOR/CONVERT
-- =============================================================================
map("n", "<leader>rc", [[:s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<cr><cmd>noh<cr>]], { desc = "Title case line" })
map("n", "<leader>r4", "<cmd>%s/\t/    /g<cr><cmd>noh<cr>", { desc = "Convert tabs to 4 spaces" })
map("n", "<leader>r2", "<cmd>%s/\t/  /g<cr><cmd>noh<cr>", { desc = "Convert tabs to 2 spaces" })

-- =============================================================================
-- MAKE COMMANDS
-- =============================================================================
map("n", "<leader>mk", "<cmd>make<cr>", { desc = "Run make" })
map("n", "<leader>mo", "<cmd>make | copen<cr>", { desc = "Make and open quickfix" })
map("n", "<leader>mt", "<cmd>make && make test<cr>", { desc = "Make and test" })

-- =============================================================================
-- RELOAD/RESTART
-- =============================================================================
map("n", "<leader>rs", "<cmd>source $MYVIMRC<cr><cmd>nohlsearch<cr>", { desc = "Reload config" })

-- =============================================================================
-- SEARCH/HIGHLIGHT
-- =============================================================================
map("n", "<leader>hn", [[/[^\x00-\x7F]<cr>]], { desc = "Highlight non-ASCII" })

-- =============================================================================
-- TMUX NAVIGATOR (explicit mappings to ensure they work)
-- =============================================================================
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true, desc = "Navigate left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true, desc = "Navigate down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Navigate up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Navigate right" })
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true, desc = "Navigate previous" })

-- =============================================================================
-- LSP KEYMAPS (base - overridden by on_attach in lsp.lua)
-- =============================================================================
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Diagnostics (replacing ALE mappings)
map("n", "<leader>ae", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "<leader>aE", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>ad", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>al", "<cmd>lua require('lint').try_lint()<cr>", { desc = "Run linter" })
map("n", "<leader>af", vim.lsp.buf.references, { desc = "Find references" })

-- =============================================================================
-- COMMAND ABBREVIATIONS (typos)
-- =============================================================================
vim.cmd([[
  cnoreabbrev Wq wq
  cnoreabbrev W w
  cnoreabbrev WQ wq
  cnoreabbrev Q q
]])

-- =============================================================================
-- DIAGNOSTIC SIGNS
-- =============================================================================
vim.fn.sign_define("DiagnosticSignError", { text = "✖", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })
