require("xor.core.keymaps")
require("xor.core.lazy")
require("xor.core.options")

-- Configure nvim-cmp
require("cmp").setup({
	sources = {
		{ name = "nvim_lsp" },
		{ name = "cmp-buffer" },
		{ name = "cmp-nvim-lua" },
		{ name = "cmp-path" },
		{ name = "cmp-calc" },
	},
})

-- Configure copilot-cmp
require("copilot_cmp").setup()
