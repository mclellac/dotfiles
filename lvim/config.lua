reload "user.plugins"
reload "user.options"
reload "user.keymaps"
reload "user.lsp"
reload "user.smoothie"
reload "user.harpoon"
reload "user.autocommands"
reload "user.webdev-icons"
reload "user.cybu"
reload "user.neotest"
reload "user.surround"
reload "user.bookmark"
reload "user.todo-comments"
reload "user.jaq"
reload "user.fidget"
reload "user.lab"
reload "user.git"
reload "user.zen-mode"
reload "user.inlay-hints"
reload "user.telescope"
reload "user.bqf"
reload "user.dial"
reload "user.numb"
reload "user.treesitter"
reload "user.neogit"
reload "user.colorizer"
reload "user.lualine"
reload "user.tabnine"
reload "user.copilot"
-- reload "user.chatgpt"
reload "user.whichkey"
reload "user.neoai"
reload "user.cmp"
reload "user.nvimtree"
reload "nostr"
reload "user.astro-tools"
reload "user.matchup"
reload "user.modicator"


local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ name = "black" },
	{ name = "stylua" },
	{
		name = "clang_format",
		args = { "--style=chromium" },
	},
	{
		name = "prettier",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespace
		-- options such as `--line-width 80` become either `{"--line-width", "80"}` or `{"--line-width=80"}`
		args = { "--print-width", "100" },
		---@usage only start in these filetypes, by default it will attach to all filetypes it supports
		filetypes = { "typescript", "typescriptreact", "javascript" },
	},
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{ name = "flake8", filetypes = { "python" } },
	{ name = "hadolint", filetypes = { "dockerfile" } },
	{
		name = "shellcheck",
		args = { "--severity", "warning" },
	},
	{ name = "cpplint", filetypes = { "cpp" } },
})

local clangd_flags = {
	"--all-scopes-completion",
	"--suggest-missing-includes",
	"--background-index",
	"--pch-storage=disk",
	"--cross-file-rename",
	"--log=info",
	"--completion-style=detailed",
	"--enable-config", -- clangd 11+ supports reading from .clangd configuration file
	"--clang-tidy",
	"--offset-encoding=utf-16", --temporary fix for null-ls
	"--clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
	"--fallback-style=Google",
	"--header-insertion=never",
	"--query-driver=<list-of-white-listed-complers>",
}

local clangd_bin = "clangd"

local opts = {
	cmd = { clangd_bin, unpack(clangd_flags) },
}
require("lvim.lsp.manager").setup("clangd", opts)
