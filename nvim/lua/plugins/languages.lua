return {
	{
		"whoissethdaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
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
							-- The VARNISHLS_VCC_PATHS is crucial for varnishls to find its VCC files.
							-- User needs to download VCC-files.zip from varnishls GitHub releases page,
							-- extract its content, and place it under ~/.config/dotfiles/nvim/vcc_files/
							-- e.g., ~/.config/dotfiles/nvim/vcc_files/vcc/std.vcc
							-- The VARNISHLS_VCC_PATHS environment variable was removed
							-- as the VCC files are compiled VCL, not source files for the LSP.
							-- If varnishls needs VMOD definitions, they are likely bundled or
							-- expected to be found from a local Varnish installation.
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
		opts = {},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "pylint", "ruff" },
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
				python = { "black" },
				rust = { "rustfmt" },
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
}
