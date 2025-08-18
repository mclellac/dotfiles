-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set the background to none (transparent)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
