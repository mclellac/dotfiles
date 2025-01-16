return {
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        window = {
          position = "left",
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_name = {
              ".DS_Store",
              "thumbs.db",
            },
            never_show = { ".git" },
          },
        },
      },
      init = function()
        -- do nothing
      end,
    },
  }