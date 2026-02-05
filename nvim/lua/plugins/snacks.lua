return {
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = true },
      indent = { enabled = false },
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
