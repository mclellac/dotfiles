-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Paste the clipboard register
vim.keymap.set("n", "<leader>p", '"0p', { desc = "Paste after cursor" })
vim.keymap.set("x", "<leader>p", '"0p', { desc = "Paste after cursor" })
vim.keymap.set("n", "<leader>P", '"0P', { desc = "Paste before cursor" })
vim.keymap.set("x", "<leader>P", '"0P', { desc = "Paste before cursor" })

-- Refactor extract code to function
-- vim.keymap.set("x", "<leader>re", ":Refactor extract ", { desc = "Refactor extract" })

-- Delete all buffers but the current one --
vim.keymap.set("n", "<leader>bq", '<Esc>:%bdelete|edit #|normal`"<cr>')

-- Disable keymaps ...
-- Insert mode
vim.api.nvim_set_keymap("i", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Nop>", { noremap = true, silent = true })
-- Normal mode
vim.api.nvim_set_keymap("n", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-k>", "<Nop>", { noremap = true, silent = true })
-- Visual block mode
vim.api.nvim_set_keymap("x", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "J", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "K", "<Nop>", { noremap = true, silent = true })