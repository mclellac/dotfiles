return {
	"varnishcache-friends/vim-varnish",
	ft = "vcl",
	config = function()
		vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
			pattern = "vcl",
			callback = function()
				vim.cmd([[syntax sync fromstart]])
				vim.opt_local.redrawtime = 10000
			end,
		})
	end,
}
