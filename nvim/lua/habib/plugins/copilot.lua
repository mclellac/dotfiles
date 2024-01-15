return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	build = ":Copilot auth",
	opts = {
		-- suggestion = { enabled = false },
		suggestion = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				accept = "<C-j>",
				accept_line = "<C-l>",
				accept_word = "<C-k>",
				next = "<C-]>",
				prev = "<C-[>",
				dismiss = "<C-c>",
			}, 
		 },
		panel = { enabled = true },
		filetypes = {
			python = true,
			markdown = true,
			help = true,
		},
	},
}
