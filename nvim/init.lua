-- set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")
-- minimize terminal split
vim.keymap.set("n", "<C-g>", "3<C-w>_")
