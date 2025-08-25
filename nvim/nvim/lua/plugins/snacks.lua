return {
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = {
        hidden = true, -- for hidden files
        ignored = true, -- for .gitignore files
        sources = {
          explorer = {
            layout = { layout = { position = "left" } },
            follow_file = true,
            tree = true,
            focus = "list",
            auto_close = true,
          },
        },
      },
    },
  },
}
