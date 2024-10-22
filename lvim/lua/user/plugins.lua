-- ~/.config/lvim/lua/user/plugins.lua
lvim.plugins = {
  { "folke/trouble.nvim" },
  { "AckslD/swenv.nvim" },
  { "rose-pine/neovim" },
  { "nordtheme/vim" },
  { "folke/todo-comments.nvim" },
  { "varnishcache-friends/vim-varnish" },
  { "HiPhish/rainbow-delimiters.nvim" },
  { "nvim-lua/plenary.nvim" },
  { "kylechui/nvim-surround" },
  { "christianchiarulli/harpoon" },
  { "ellisonleao/glow.nvim" },
  { "mfussenegger/nvim-dap-python" },
  { "nvim-neotest/neotest" },
  { "nvim-neotest/neotest-python" },
  { "nvim-neotest/nvim-nio" },
}

require('swenv').setup({
  get_venvs = function()
      local venvs = {}
      local venv_path = vim.fn.getcwd() .. '/.venv/bin/python'
      if vim.fn.filereadable(venv_path) == 1 then
          table.insert(venvs, venv_path)
      end
      return venvs
  end,
  post_set_venv = function()
      vim.cmd('LspRestart')  -- Restart LSP after switching venv
  end,
})