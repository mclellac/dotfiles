return {
	-- Comprehensive Kubernetes and Helm integration
	{
		"h4ckm1n-dev/kube-utils-nvim",
		ft = { "yaml", "yml" }, -- Kube-utils works primarily with YAML files
		opts = {},
		dependencies = {
			"nvim-telescope/telescope.nvim", -- Required for some features
		},
	},
}
