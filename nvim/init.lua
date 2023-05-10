--   _           _   _         _
--  (_)  _ __   (_) | |_      | |  _   _    __ _
--  | | | '_ \  | | | __|     | | | | | |  / _` |
--  | | | | | | | | | |_   _  | | | |_| | | (_| |
--  |_| |_| |_| |_|  \__| (_) |_|  \__,_|  \__,_|-

vim.loader.enable()

require("keymaps") -- leader key is set before lazy
require("options")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"



if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup("plugins") -- load and setup plugins

require("lazy").setup({
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  },
})


require("autocommands")
