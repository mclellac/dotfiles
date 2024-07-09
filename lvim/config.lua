-- Read the docs: https://www.lunarvim.org/docs/configuration
-- install plugins
lvim.plugins = {
	"rose-pine/neovim", as = "rose-pine",
	"nvim-neotest/nvim-nio",
	"ChristianChiarulli/swenv.nvim",
	"stevearc/dressing.nvim",
	"mfussenegger/nvim-dap-python",
	"nvim-neotest/neotest",
	"nvim-neotest/neotest-python",
	"lervag/vimtex",
	"kdheepak/cmp-latex-symbols",
	"KeitaNakamura/tex-conceal.vim",
	"SirVer/ultisnips",
	"simrat39/rust-tools.nvim",
	{
		"saecki/crates.nvim",
		version = "v0.3.0",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup({
				null_ls = {
					enabled = true,
					name = "crates.nvim",
				},
				popup = {
					border = "rounded",
				},
			})
		end,
	},
	{
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup()
		end,
	},
}

-- set default colorscheme - change with <Leader>sc
lvim.colorscheme = 'rose-pine'
lvim.builtin.theme.name = 'rose-pine'

-- automatically install python syntax highlighting
lvim.builtin.treesitter.ensure_installed = {
	"python",
	"lua",
	"rust",
	"toml",
	"latex",
}

-- setup formatting
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({ { name = "black" } })
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.py" }

-- setup linting
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({ { command = "flake8", filetypes = { "python" } } })

-- setup debug adapter
lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
pcall(function()
	require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
end)

-- setup testing
require("neotest").setup({
	adapters = {
		require("neotest-python")({
			-- Extra arguments for nvim-dap configuration
			-- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
			dap = {
				justMyCode = false,
				console = "integratedTerminal",
			},
			args = { "--log-level", "DEBUG", "--quiet" },
			runner = "pytest",
		}),
	},
})

lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>", "Test Method" }
lvim.builtin.which_key.mappings["dM"] =
	{ "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Test Method DAP" }
lvim.builtin.which_key.mappings["df"] = {
	"<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>",
	"Test Class",
}
lvim.builtin.which_key.mappings["dF"] = {
	"<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
	"Test Class DAP",
}
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }

-- binding for switching
lvim.builtin.which_key.mappings["C"] = {
	name = "Python",
	c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

lvim.format_on_save = false
vim.diagnostic.config({ virtual_text = true })
lvim.builtin.treesitter.highlight.enable = true

-- Setup Lsp.
local capabilities = require("lvim.lsp").common_capabilities()
require("lvim.lsp.manager").setup("texlab", {
	on_attach = require("lvim.lsp").common_on_attach,
	on_init = require("lvim.lsp").common_on_init,
	capabilities = capabilities,
})

-- Setup formatters.
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "latexindent", filetypes = { "tex" } },
})

-- Set a linter.
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{ command = "chktex", filetypes = { "tex" } },
})

-- UltiSnip configuration.
vim.cmd([[
  let g:UltiSnipsExpandTrigger="<CR>"
  let g:UltiSnipsJumpForwardTrigger="<Plug>(ultisnips_jump_forward)"
  let g:UltiSnipsJumpBackwardTrigger="<Plug>(ultisnips_jump_backward)"
  let g:UltiSnipsListSnippets="<c-x><c-s>"
  let g:UltiSnipsRemoveSelectModeMappings=0
  let g:UltiSnipsEditSplit="tabdo"
  let g:UltiSnipsSnippetDirectories=[$HOME."/.config/nvim/UltiSnips"]
]])

-- Vimtex configuration.
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_quickfix_enabled = 0

-- Setup cmp.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("LaTeXGroup", { clear = true }),
	pattern = "tex",
	callback = function()
		require("user.cmp")
	end,
})

-- Mappings
lvim.builtin.which_key.mappings["C"] = {
	name = "LaTeX",
	m = { "<cmd>VimtexContextMenu<CR>", "Open Context Menu" },
	u = { "<cmd>VimtexCountLetters<CR>", "Count Letters" },
	w = { "<cmd>VimtexCountWords<CR>", "Count Words" },
	d = { "<cmd>VimtexDocPackage<CR>", "Open Doc for package" },
	e = { "<cmd>VimtexErrors<CR>", "Look at the errors" },
	s = { "<cmd>VimtexStatus<CR>", "Look at the status" },
	a = { "<cmd>VimtexToggleMain<CR>", "Toggle Main" },
	v = { "<cmd>VimtexView<CR>", "View pdf" },
	i = { "<cmd>VimtexInfo<CR>", "Vimtex Info" },
	l = {
		name = "Clean",
		l = { "<cmd>VimtexClean<CR>", "Clean Project" },
		c = { "<cmd>VimtexClean<CR>", "Clean Cache" },
	},
	c = {
		name = "Compile",
		c = { "<cmd>VimtexCompile<CR>", "Compile Project" },
		o = {
			"<cmd>VimtexCompileOutput<CR>",
			"Compile Project and Show Output",
		},
		s = { "<cmd>VimtexCompileSS<CR>", "Compile project super fast" },
		e = { "<cmd>VimtexCompileSelected<CR>", "Compile Selected" },
	},
	r = {
		name = "Reload",
		r = { "<cmd>VimtexReload<CR>", "Reload" },
		s = { "<cmd>VimtexReloadState<CR>", "Reload State" },
	},
	o = {
		name = "Stop",
		p = { "<cmd>VimtexStop<CR>", "Stop" },
		a = { "<cmd>VimtexStopAll<CR>", "Stop All" },
	},
	t = {
		name = "TOC",
		o = { "<cmd>VimtexTocOpen<CR>", "Open TOC" },
		t = { "<cmd>VimtexTocToggle<CR>", "Toggle TOC" },
	},
}




vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })

local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")

local codelldb_path = mason_path .. "bin/codelldb"
local liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb"
local this_os = vim.loop.os_uname().sysname

-- The path in windows is different
if this_os:find("Windows") then
	codelldb_path = mason_path .. "packages\\codelldb\\extension\\adapter\\codelldb.exe"
	liblldb_path = mason_path .. "packages\\codelldb\\extension\\lldb\\bin\\liblldb.dll"
else
	-- The liblldb extension is .so for linux and .dylib for macOS
	liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
end

pcall(function()
	require("rust-tools").setup({
		tools = {
			executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
			reload_workspace_from_cargo_toml = true,
			runnables = {
				use_telescope = true,
			},
			inlay_hints = {
				auto = true,
				only_current_line = false,
				show_parameter_hints = false,
				parameter_hints_prefix = "<-",
				other_hints_prefix = "=>",
				max_len_align = false,
				max_len_align_padding = 1,
				right_align = false,
				right_align_padding = 7,
				highlight = "Comment",
			},
			hover_actions = {
				border = "rounded",
			},
			on_initialized = function()
				vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
					pattern = { "*.rs" },
					callback = function()
						local _, _ = pcall(vim.lsp.codelens.refresh)
					end,
				})
			end,
		},
		dap = {
			-- adapter= codelldb_adapter,
			adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
		},
		server = {
			on_attach = function(client, bufnr)
				require("lvim.lsp").common_on_attach(client, bufnr)
				local rt = require("rust-tools")
				vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
			end,

			capabilities = require("lvim.lsp").common_capabilities(),
			settings = {
				["rust-analyzer"] = {
					lens = {
						enable = true,
					},
					checkOnSave = {
						enable = true,
						command = "clippy",
					},
				},
			},
		},
	})
end)

lvim.builtin.dap.on_config_done = function(dap)
	dap.adapters.codelldb = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
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
end

vim.api.nvim_set_keymap("n", "<m-d>", "<cmd>RustOpenExternalDocs<Cr>", { noremap = true, silent = true })

lvim.builtin.which_key.mappings["C"] = {
	name = "Rust",
	r = { "<cmd>RustRunnables<Cr>", "Runnables" },
	t = { "<cmd>lua _CARGO_TEST()<cr>", "Cargo Test" },
	m = { "<cmd>RustExpandMacro<Cr>", "Expand Macro" },
	c = { "<cmd>RustOpenCargo<Cr>", "Open Cargo" },
	p = { "<cmd>RustParentModule<Cr>", "Parent Module" },
	d = { "<cmd>RustDebuggables<Cr>", "Debuggables" },
	v = { "<cmd>RustViewCrateGraph<Cr>", "View Crate Graph" },
	R = {
		"<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
		"Reload Workspace",
	},
	o = { "<cmd>RustOpenExternalDocs<Cr>", "Open External Docs" },
	y = { "<cmd>lua require'crates'.open_repository()<cr>", "[crates] open repository" },
	P = { "<cmd>lua require'crates'.show_popup()<cr>", "[crates] show popup" },
	i = { "<cmd>lua require'crates'.show_crate_popup()<cr>", "[crates] show info" },
	f = { "<cmd>lua require'crates'.show_features_popup()<cr>", "[crates] show features" },
	D = { "<cmd>lua require'crates'.show_dependencies_popup()<cr>", "[crates] show dependencies" },
}
