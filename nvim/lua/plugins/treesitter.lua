-- Treesitter: syntax highlighting and more
-- Note: Neovim 0.11+ has built-in treesitter support

return {
  -- Treesitter core (for auto-installing parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "comment",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "gitcommit",
        "gitignore",
        "go",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "ruby",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Enable additional vim regex highlighting for richer colors
        additional_vim_regex_highlighting = { "ruby", "python" },
      },
      indent = { enable = true },
    },
  },

  -- Rainbow delimiters: colorful brackets/parentheses
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- mini.ai for function/class text objects (daf, dif, etc.)
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          -- Function text object (works with treesitter)
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          -- Class text object
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          -- Block text object
          b = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
          -- Conditional text object
          o = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
          -- Loop text object
          l = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
          -- Parameter/argument text object
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
        },
      }
    end,
  },

  -- Treesitter context (sticky headers)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 1,
      trim_scope = "outer",
      mode = "cursor",
    },
    keys = {
      { "<leader>tc", "<cmd>TSContextToggle<cr>", desc = "Toggle treesitter context" },
    },
  },
}
