require("core.lazy")

require("mini.animate").setup()

require("mini.indentscope").setup({
  lazy = true,
  enabled = true,
  version = '*', -- wait till new 0.7.0 release to put it back on semver
  -- event = "BufReadPre",
  opts = {
    symbol = "│",
    delay = 100,
    options = { try_as_border = false },
  },
  config = function(_, opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
      },
      callback = function()
        vim.b.miniindentscope_disable = false
      end,
    })
    require("mini.indentscope").setup(opts)
  end,
})

require("notify").setup({
  background_colour = "#000000",
})