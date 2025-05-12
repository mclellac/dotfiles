require("mason-lspconfig").setup({

	ensure_installed = { "ansible-language-server", "ansible-lint", "lua_ls", "rust_analyzer" },

	automatic_enable = true,

	--automatic_enable = {
	--    "lua_ls",
	--    "vimls",
	--},
})
