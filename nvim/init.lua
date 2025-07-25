-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.filetype.add({ extension = { vcl = "vcl", vtc = "vtc" } })
vim.lsp.start({
  name = "varnishls",
  cmd = { "varnishls", "lsp", "--stdio" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
})
