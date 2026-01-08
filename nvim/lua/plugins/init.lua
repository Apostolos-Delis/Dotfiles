-- Plugin specifications for lazy.nvim
-- This file returns a table of all plugin specs

return {
  -- Import all plugin modules
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.treesitter" },
  { import = "plugins.lsp" },
  { import = "plugins.completion" },
  { import = "plugins.telescope" },
  { import = "plugins.git" },
}
