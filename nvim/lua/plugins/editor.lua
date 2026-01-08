-- Editor plugins: file explorer, comments, tmux integration

return {
  -- File explorer: oil.nvim (edit filesystem like a buffer)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<C-f>", "<cmd>Oil<cr>", desc = "Open file explorer" },
    },
    cmd = { "Oil" },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
          return vim.startswith(name, ".")
        end,
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_split",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["q"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      float = {
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
    },
  },

  -- Comments (replaces NERDCommenter)
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Toggle line comment" },
      { "gc", mode = { "n", "v" }, desc = "Toggle comment" },
      { "//", function() require("Comment.api").toggle.linewise.current() end, mode = "n", desc = "Toggle comment" },
      { "//", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", mode = "v", desc = "Toggle comment" },
    },
    opts = {
      padding = true,
      sticky = true,
      toggler = {
        line = "gcc",
        block = "gbc",
      },
      opleader = {
        line = "gc",
        block = "gb",
      },
    },
  },

  -- Tmux navigator (keeping vim-tmux-navigator as it's still the best)
  -- Must load eagerly for mappings to work with tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_disable_when_zoomed = 1
      -- Let the plugin create its own mappings
    end,
  },

  -- Auto pairs for brackets/quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    },
  },

  -- Surround (vim-surround replacement)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Better escape (jk to exit insert mode)
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 300,
      mappings = {
        i = {
          j = {
            k = "<Esc>",
          },
        },
      },
    },
  },
}
