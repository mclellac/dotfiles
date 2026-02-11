return {
  -- Comprehensive Kubernetes and Helm integration
  {
    "h4ckm1n-dev/kube-utils-nvim",
    ft = { "yaml", "yml" }, -- Kube-utils works primarily with YAML files
    opts = {
      -- You can customize kube-utils-nvim options here
      -- refer to https://github.com/h4ckm1n-dev/kube-utils-nvim#setup
    },
    dependencies = {
      "nvim-telescope/telescope.nvim", -- Required for some features
    },
    config = function()
      require("kube-utils").setup()
    end,
  },
}