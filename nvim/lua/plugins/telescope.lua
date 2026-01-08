-- Telescope: fuzzy finding

-- Ensure compatibility shim for Neovim 0.11+ is set before Telescope loads
-- (ft_to_lang was renamed to get_lang in Neovim 0.11)
if vim.treesitter and vim.treesitter.language then
  if not vim.treesitter.language.ft_to_lang and vim.treesitter.language.get_lang then
    vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    keys = {
      -- File finding (matches your old fzf mappings)
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git files" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>ft", "<cmd>Telescope tags<cr>", desc = "Tags" },
      { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer lines" },

      -- Git files grep - your ,gf mapping!
      { "<leader>gf", "<cmd>Telescope live_grep<cr>", desc = "Live grep (git files)" },
      { "<leader>gg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>gw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },

      -- Git (using gS/gB to not conflict with Fugitive ,gs ,gb)
      { "<leader>gS", "<cmd>Telescope git_status<cr>", desc = "Git status (Telescope)" },
      { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },

      -- Modified git files (like your old ,fm mapping)
      { "<leader>fm", "<cmd>Telescope git_status<cr>", desc = "Modified git files" },

      -- LSP
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },

      -- Misc
      { ";", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>f/", "<cmd>Telescope search_history<cr>", desc = "Search history" },
      { "<leader>f:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>fH", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
    },
    opts = function()
      local actions = require("telescope.actions")

      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          entry_prefix = "  ",
          -- Disable treesitter highlighting in previewer to avoid ft_to_lang issues on Neovim 0.11+
          preview = {
            treesitter = false,
          },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          winblend = 0,
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.lock",
            "%.min.js",
            "%.min.css",
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
            n = {
              ["<Esc>"] = actions.close,
              ["q"] = actions.close,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob",
            "!.git/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden", "--glob", "!.git/" }
            end,
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      -- Load fzf extension if available
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
