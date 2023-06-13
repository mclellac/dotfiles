require("core.lazy")

--require("mini.animate").setup()
--require("mini.colors").setup()
require("mini.indentscope").setup()

require("notify").setup({
  background_colour = "#000000",
})

-- In init.lua
vim.cmd("highlight IndentScope guifg=#00FF62")
