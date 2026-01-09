-- LSP configuration: language servers, formatting, linting

return {
  -- Mason: LSP/linter/formatter installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason-lspconfig: bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- On attach function for all LSP servers
      local on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Go to references")
        map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
        map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")

        -- Documentation
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

        -- Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")

        -- Diagnostics
        map("n", "<leader>ae", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "<leader>aE", vim.diagnostic.goto_prev, "Previous diagnostic")
        map("n", "<leader>ad", vim.diagnostic.open_float, "Show diagnostic")
        map("n", "<leader>al", "<cmd>Telescope diagnostics bufnr=0<cr>", "Buffer diagnostics")
        map("n", "<leader>aL", "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics")

        -- Workspace
        map("n", "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace symbols")
      end

      -- Capabilities for autocompletion
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Try to get blink.cmp capabilities if available
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      -- Server-specific settings
      local server_settings = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
              completion = { callSnippet = "Replace" },
              telemetry = { enable = false },
              diagnostics = {
                globals = { "vim", "Snacks" },
              },
            },
          },
        },
      }

      -- Default handler for servers
      local default_handler = function(server_name)
        local config = {
          on_attach = on_attach,
          capabilities = capabilities,
        }
        if server_settings[server_name] then
          config = vim.tbl_deep_extend("force", config, server_settings[server_name])
        end
        require("lspconfig")[server_name].setup(config)
      end

      -- Setup mason-lspconfig with handlers
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ts_ls",
          "ruby_lsp",
          "lua_ls",
          "bashls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
        },
        automatic_installation = true,
        handlers = {
          default_handler,
        },
      })

      -- Diagnostics configuration
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })
    end,
  },

  -- LSP configuration (loaded as dependency)
  {
    "neovim/nvim-lspconfig",
    lazy = true,
  },

  -- Formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
    },
    opts = {
      -- Only define formatters you actually have installed
      formatters_by_ft = {
        python = { "black", "isort" },
        lua = { "stylua" },
        ruby = function(bufnr)
          local root = vim.fs.root(bufnr, ".git") or vim.fn.getcwd()
          if vim.fn.filereadable(root .. "/.rubocop.yml") == 1 then
            return { "rubocop" }
          end
          return { "standardrb" }
        end,
        -- Add more as you install them:
        -- javascript = { "prettier" },
        -- typescript = { "prettier" },
      },
      -- Only format on save if a formatter is available (no warnings)
      format_on_save = function(bufnr)
        -- Check if there are formatters for this buffer
        local formatters = require("conform").list_formatters(bufnr)
        if #formatters == 0 then
          return nil -- Skip formatting, no warning
        end
        return {
          timeout_ms = 3000,
          lsp_format = "fallback",
        }
      end,
      -- Don't notify about missing formatters
      notify_on_error = false,
    },
  },

  -- Linting with nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Only define linters you have installed
      lint.linters_by_ft = {
        python = { "ruff" },
        -- Add more as you install them:
        -- javascript = { "eslint" },
        -- typescript = { "eslint" },
      }

      -- Helper to get ruby linter based on project config
      local function get_ruby_linter()
        local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
        if vim.fn.filereadable(root .. "/.rubocop.yml") == 1 then
          return { "rubocop" }
        end
        return { "standardrb" }
      end

      -- Auto-lint on save (silently skip if no linter)
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          local ft = vim.bo.filetype
          if ft == "ruby" then
            lint.try_lint(get_ruby_linter())
          elseif lint.linters_by_ft[ft] then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Trouble: better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    opts = {},
  },
}
