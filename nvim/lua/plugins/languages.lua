return {
  {
    "whoissethdaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "shfmt",
        "markdownlint",
        "clang-format",
        "tflint",
        "ansible-lint",
        "ansible-language-server",
        "terraform-ls",
        "shellcheck",
        "prettier",
        "djlint",
        "ruff",
        "yaml-language-server",
        "hadolint",
        "bash-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", version = "^2.0" },
      { "mason-org/mason-lspconfig.nvim", version = "^2.0" },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

<<<<<<< HEAD
      mason_lspconfig.setup({
        ensure_installed = {
          "basedpyright",
          "rust_analyzer",
          "html",
          "cssls",
          "jinja_lsp",
          "bashls",
          "marksman",
          "lemminx",
          "clangd",
          "terraformls",
          "helm_ls",
          "ansiblels",
          "yamlls",
          "dockerls",
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({})
          end,
          ["clangd"] = function()
            lspconfig.clangd.setup({
              filetypes = { "c", "cpp", "objc", "objcpp" },
            })
          end,
          ["varnishls"] = function()
            lspconfig.varnishls.setup({
              cmd = { vim.fn.expand("~/bin/varnishls") },
              filetypes = { "vcl" },
              on_attach = function(client, _)
                client.server_capabilities.semanticTokensProvider = nil
              end,
            })
          end,
          -- Explicitly configure yamlls for Kubernetes schemas
          ["yamlls"] = function()
            lspconfig.yamlls.setup({
              settings = {
                yaml = {
                  schemaStore = {
                    enable = true,
                    url = "https://www.schemastore.org/api/json/catalog.json",
                  },
                  schemas = {
                    ["kubernetes"] = {
                      "*-k8s.yaml",
                      "*.kubernetes.yaml",
                      "*.kube.yaml",
                      "*deployment.yaml",
                      "*service.yaml",
                      "*ingress.yaml",
                      "*configmap.yaml",
                      "*secret.yaml",
                      "*pod.yaml",
                      "*.kustomization.yaml",
                      "*.cluster.yaml",
                      "*.flux.yaml",
                      "*.argocd.yaml",
                    },
                    ["https://helm.sh/schemas/helm-template-0.2.0.json"] = "*/templates/*.yaml",
                  },
                },
              },
            })
          end,
        },
      })
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
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "sql",
        "html",
        "css",
        "comment",
        "python",
        "bash",
        "markdown",
        "markdown_inline",
        "regex",
        "vim",
        "yaml",
        "dockerfile",
        "nginx",
        "terraform",
        "helm",
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
=======
			mason_lspconfig.setup({
				ensure_installed = {
					"basedpyright",
					"html",
					"cssls",
					"jinja_lsp",
					"bashls",
					"marksman",
					"lemminx",
					"clangd",
					"terraformls",
					"helm_ls",
					"ansiblels",
					"yamlls",
					"dockerls",
				},
				handlers = {
					function(server_name)
						lspconfig[server_name].setup({})
					end,
					["clangd"] = function()
						lspconfig.clangd.setup({
							filetypes = { "c", "cpp", "objc", "objcpp" },
						})
					end,
					["varnishls"] = function()
						lspconfig.varnishls.setup({
							cmd = { vim.fn.expand("~/bin/varnishls") },
							filetypes = { "vcl" },
							on_attach = function(client, _)
								client.server_capabilities.semanticTokensProvider = nil
							end,
						})
					end,
					-- Explicitly configure yamlls for Kubernetes schemas
					["yamlls"] = function()
						lspconfig.yamlls.setup({
							settings = {
								yaml = {
									schemaStore = {
										enable = true,
										url = "https://www.schemastore.org/api/json/catalog.json",
									},
									schemas = {
										["kubernetes"] = {
											"*-k8s.yaml",
											"*.kubernetes.yaml",
											"*.kube.yaml",
											"*deployment.yaml",
											"*service.yaml",
											"*ingress.yaml",
											"*configmap.yaml",
											"*secret.yaml",
											"*pod.yaml",
											"*.kustomization.yaml",
											"*.cluster.yaml",
											"*.flux.yaml",
											"*.argocd.yaml",
										},
										["https://helm.sh/schemas/helm-template-0.2.0.json"] = "*/templates/*.yaml",
									},
								},
							},
						})
					end,
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
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
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
					}),
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"sql",
				"html",
				"css",
				"comment",
				"python",
				"bash",
				"markdown",
				"markdown_inline",
				"regex",
				"vim",
				"yaml",
				"dockerfile",
				"nginx",
				"terraform",
				"helm",
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
>>>>>>> f29fede (bump)

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

<<<<<<< HEAD
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
    opts = {},
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        rust = { "rustc" },
        html = { "djlint" },
        jinja = { "djlint" },
        sh = { "shellcheck" },
        markdown = { "markdownlint" },
        c = { "clang-tidy" },
        terraform = { "tflint" },
        helm = { "helmlint" },
        ansible = { "ansible-lint" },
        dockerfile = { "hadolint" },
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
        python = { "ruff_format" },
        --rust = { "rustfmt" },
        html = { "djlint" },
        jinja = { "djlint" },
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
=======
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
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "ruff" },
				html = { "djlint" },
				jinja = { "djlint" },
				sh = { "shellcheck" },
				markdown = { "markdownlint" },
				c = { "clang-tidy" },
				terraform = { "tflint" },
				helm = { "helmlint" },
				ansible = { "ansible-lint" },
				dockerfile = { "hadolint" },
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
				python = { "ruff_format" },
				html = { "djlint" },
				jinja = { "djlint" },
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
>>>>>>> f29fede (bump)
}

