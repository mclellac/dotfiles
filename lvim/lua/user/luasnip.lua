-- ~/.config/lvim/lua/user/luasnip.lua

local luasnip = require('luasnip')

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Add more snippets
luasnip.snippets = {
  all = {
    luasnip.parser.parse_snippet("expand", "-- This is an expandable snippet"),
  },
  python = {
    luasnip.parser.parse_snippet("def", "def ${1:function_name}(${2:args}):\n\t${0:pass}"),
    luasnip.parser.parse_snippet("class", "class ${1:ClassName}(${2:object}):\n\tdef __init__(self, ${3:args}):\n\t\t${0:pass}"),
  },
}
