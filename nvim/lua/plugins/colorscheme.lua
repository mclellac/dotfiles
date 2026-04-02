return {
	{
		"Mofiqul/adwaita.nvim",
		lazy = true,

		config = function()
			vim.g.adwaita_darker = true -- for darker version
			vim.g.adwaita_disable_cursorline = true -- to disable cursorline
			vim.g.adwaita_transparent = true -- makes the background transparent
			--vim.cmd("colorscheme adwaita")
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		opts = {
			bold = false,
			italic = {
				strings = false,
				emphasis = false,
				comments = false,
				operators = false,
				folds = false,
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		opts = {
			transparent_background = true,
			flavour = "mocha",

			color_overrides = {
				mocha = {
					-- base = "#111622",
				},
			},
		},
	},
	{
		"marko-cerovac/material.nvim",
		lazy = false,
		priority = 1000,
		opts = function()
			return {
				style = "palenight",
				italic_comments = false,
				italic_keywords = false,
				italic_functions = false,
				italic_variables = false,
				disable = {
					background = true,
				},
				custom_highlight_overrides = {
					MiniFilesHidden = { fg = "#70788c" },
					NvimTreeHiddenFile = { fg = "#70788c" },
					NeoTreeHiddenFile = { fg = "#70788c" },
					Comment = { italic = false },
				},
			}
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			transparent_background = true,
			variant = "main",

			setmetatableyles = {
				bold = true,
				italic = false,
			},
		},
		lazy = true,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "material",
		},
	},
}
