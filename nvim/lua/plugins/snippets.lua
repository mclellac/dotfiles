return {
  {
    "L3MON4D3/LuaSnip",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<leader>cs",
        function()
          require("luasnip.loaders").edit_snippet_files()
        end,
        desc = "Edit Snippets",
      },
    },
  },
}
