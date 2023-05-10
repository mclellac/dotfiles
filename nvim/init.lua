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

-- require("lazy").setup("plugins") -- load and setup plugins

require("lazy").setup("plugins", {
 defaults = { lazy = true },
 install = { colorscheme = { "tokyonight" } },
 checker = { enabled = true },
 change_detection = {
  notify = true,
 },
 performance = {
  rtp = {
   disabled_plugins = {
    "gzip",
    "matchit",
    "matchparen",
    "netrwPlugin",
    "tarPlugin",
    "tohtml",
    "tutor",
    "zipPlugin",
   },
  },
 },
})

require("autocommands")
require("whichkey")
