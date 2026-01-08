-- UI plugins: theme, statusline, icons, indent guides

return {
  -- Colorscheme: OneDark (Lua version)
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = true, -- Enable transparency
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        lualine = {
          transparent = true, -- Transparent statusline
        },
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
      require("onedark").load()
    end,
  },

  -- Icons (required by many plugins)
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Statusline: lualine (replaces vim-airline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "onedark",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "fugitive", "lazy", "oil", "quickfix" },
    },
  },

  -- Indent guides (replaces indentLine)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "dashboard",
          "lazy",
          "mason",
          "notify",
          "oil",
        },
      },
    },
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = { enabled = true },
      },
      spec = {
        { "<leader>f", group = "find/file" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunks" },
        { "<leader>t", group = "toggle" },
        { "<leader>e", group = "edit config" },
        { "<leader>d", group = "delete/clean" },
        { "<leader>r", group = "refactor" },
        { "<leader>w", group = "window" },
        { "<leader>b", group = "buffer" },
        { "<leader>a", group = "diagnostics" },
        { "<leader>s", group = "spell/session" },
        { "<leader>m", group = "make" },
        { "<leader>c", group = "code" },
        { "<leader>x", group = "trouble" },
      },
    },
  },

  -- Trouble for better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
    opts = {},
  },

  -- Snacks.nvim for dashboard and utilities
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "c", desc = "Config", action = ":e ~/.config/nvim/lua/init.lua" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false }, -- We use signcolumn
      words = { enabled = true },
    },
    keys = {
      { "<leader>st", function() Snacks.dashboard() end, desc = "Dashboard" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    },
  },
}
