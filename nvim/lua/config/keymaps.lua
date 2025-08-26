local keymap = vim.keymap

local opts = { noremap = true, silent = true }

-- Paste the clipboard register
vim.keymap.set("n", "<leader>p", '"0p', { desc = "Paste after cursor" })
vim.keymap.set("x", "<leader>p", '"0p', { desc = "Paste after cursor" })
vim.keymap.set("n", "<leader>P", '"0P', { desc = "Paste before cursor" })
vim.keymap.set("x", "<leader>P", '"0P', { desc = "Paste before cursor" })

-- Delete all buffers but the current one --
vim.keymap.set("n", "<leader>bq", '<Esc>:%bdelete|edit #|normal`"<cr>')

--- WINDOW MANAGEMENT ---------------------------------------------------------
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", opts) -- SPLIT VERTICALLY
vim.keymap.set("n", "<leader>sh", ":split<CR>", opts) -- SPLIT HORIZONTALLY- Add any additional keymaps here
