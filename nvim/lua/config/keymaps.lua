-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

local opts = { noremap = true, silent = true }

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

-- DIRECTORY NAVIGATION ------------------------------------------------------
keymap.set("n", "<leader>m", ":NvimTreeFocus<CR>", opts)
keymap.set("n", "<leader>f", ":NvimTreeToggle<CR>", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts) -- NAVIGATE [^] UP
keymap.set("n", "<C-h>", "<C-w>h", opts) -- NAVIGATE [<] LEFT
keymap.set("n", "<C-l>", "<C-w>l", opts) -- NAVIGATE [>] RIGHT
keymap.set("n", "<C-j>", "<C-w>j", opts) -- NAVIGATE [v] DOWN

-- WINDOW MANAGEMENT ---------------------------------------------------------
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts) -- SPLIT VERTICALLY
keymap.set("n", "<leader>sh", ":split<CR>", opts) -- SPLIT HORIZONTALLY

-- INDENT --------------------------------------------------------------------
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- COMMENTS ------------------------------------------------------------------
vim.api.nvim_set_keymap("n", "<C-_>", "gcc", { noremap = false })
vim.api.nvim_set_keymap("v", "<C-_>", "gcc", { noremap = false })

