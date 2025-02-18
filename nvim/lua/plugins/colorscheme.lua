return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      bold = false,
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          base = "#111622",
        },
      },
    },
  },
  { "marko-cerovac/material.nvim" },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main",
      disable_background = is_transparent,
      disable_float_background = is_transparent,
      styles = {
        bold = true,
        italic = false,
        transparency = is_transparent,
      },
    },
    lazy = true,
  },
  -- set LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-dawn",
    },
  },
}
