return {
  {
    "Mofiqul/adwaita.nvim",
    lazy = false,
    priority = 1000,

    config = function()
      vim.g.adwaita_darker = false -- for darker version
      vim.g.adwaita_disable_cursorline = true -- to disable cursorline
      vim.g.adwaita_transparent = false -- makes the background transparent
      --vim.cmd("colorscheme adwaita")
    end,
  },
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
      --disable_background = is_transparent,
      --disable_float_background = is_transparent,
      setmetatableyles = {
        bold = true,
        italic = false,
        --transparency = is_transparent,
      },
    },
    lazy = true,
  },
  -- set LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "adwaita",
      --colorscheme = "rose-pine-dawn",
    },
  },
}
