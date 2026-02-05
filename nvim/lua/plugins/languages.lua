return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", version = "^2.0" },
      { "mason-org/mason-lspconfig.nvim", version = "^2.0" },
    },
    opts = {
      servers = {
        pyright = {},
        rust_analyzer = {},
        gopls = {},
        bashls = {},
        marksman = {},
        lemminx = {},
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp" },
        },
        terraformls = {},
        helm_ls = {},
        ansiblels = {},
      },
    },
  },
  {
    "whoissethdaniel/mason-tool-installer.nvim",
    dependencies = {
      { "mason-org/mason.nvim", version = "^2.0" },
    },
    opts = {
      ensure_installed = {
        "black",
        "rustfmt",
        "shfmt",
        "markdownlint",
        "clang-format",
        "tflint",
        "ansible-lint",
        "shellcheck",
        "prettier",
        "gomodifytags",
        "impl",
        "gotests",
        "delve",
        "golines",
        "gotestsum",
        "mockgen",
        "json-to-struct",
        "ginkgo",
        "richgo",
      },
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "saecki/crates.nvim",
      "chrisgrieser/nvim-various-textobjs",
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
          require("neotest-golang")({
            go_test_args = { "-v", "-count=1" },
          }),
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = {
      ensure_installed = {
        "sql",
        "gotmpl",
        "comment",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return vim.fn.exepath("python")
          end,
        },
      }

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "pylint" },
        rust = { "rustc" },
        go = { "golangci-lint" },
        sh = { "shellcheck" },
        markdown = { "markdownlint" },
        c = { "clang-tidy" },
        terraform = { "tflint" },
        helm = { "helmlint" },
        ansible = { "ansible-lint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black" },
        rust = { "rustfmt" },
        go = { "gofmt" },
        sh = { "shfmt" },
        markdown = { "markdown-it" },
        c = { "clang-format" },
        terraform = { "terraform_fmt" },
        ansible = { "ansible-lint" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = "<CMD>GoInstallBinaries<CR>",
  },
}
