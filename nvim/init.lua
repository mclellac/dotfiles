-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")


-- 80 char width lines are ridiculous
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.textwidth = 100
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "100"
  end,
})
