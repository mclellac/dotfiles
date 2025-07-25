return {
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      return {
        history = true,
        delete_check_events = "TextChanged",
        -- Load snippets from the `snippets` directory
        load_ft_func = require("luasnip.loaders.from_lua").load_ft,
      }
    end,
    config = function(_, opts)
      require("luasnip").setup(opts)
      -- Add a command to edit snippets
      vim.api.nvim_create_user_command("EditSnippets", function()
        require("luasnip.loaders").edit_snippet_files()
      end, {})
    end,
    keys = {
      {
        "<leader>cs",
        function()
          vim.cmd("EditSnippets")
        end,
        desc = "Edit Snippets",
      },
    },
  },
}
