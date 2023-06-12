require("core.lazy")

--require("mini.animate").setup()
--require("mini.indentscope").setup()

require("mini.indentscope").setup({
    lazy = true,
    enabled = true,
    version = false, -- wait till new 0.7.0 release to put it back on semver
    -- event = "BufReadPre",
    opts = {
      symbol = "▏",
      --symbol = "│",
      delay = 100,
      options = { try_as_border = false },
    },
})


require("notify").setup({
  background_colour = "#000000",
})
