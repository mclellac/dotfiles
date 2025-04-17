return {
  {
    "Mofiqul/adwaita.nvim",
    lazy = false,
    priority = 1000,

    config = function()
      vim.g.adwaita_darker = true -- for darker version
      vim.g.adwaita_disable_cursorline = true -- to disable cursorline
      vim.g.adwaita_transparent = true -- makes the background transparent
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
      transparent_background = true,
      flavour = "mocha",

      color_overrides = {
        mocha = {
          -- base = "#111622",
        },
      },
    },
  },
  {
    "marko-cerovac/material.nvim",
    lazy = false, -- Load theme early
    priority = 1000, -- Ensure it loads before plugins that depend on it
    opts = function()
      -- Configuration options based on material.nvim documentation
      -- See: https://github.com/marko-cerovac/material.nvim#configuration

      -- Example: Choose a style variant ('darker', 'palenight', 'oceanic', 'lighter', 'deep ocean')
      local style = "palenight" -- Change this to your preferred style

      -- Example: Enable/disable features (most are enabled by default)
      local disable = {
        background = true, -- enable transparency
        -- integrated_term = false, -- enable/disable integrated terminal colors
        -- integrated_search = false, -- enable/disable search highlighting colors
      }

      -- Example: Configure specific plugin integrations (optional, defaults are usually good)
      local plugins = {
        -- enable = {}, -- Specify plugins to ensure integration is enabled
        -- disable = {}, -- Specify plugins to disable integration
        -- configure = { -- Fine-tune specific plugin highlights if needed
        --   nvim_cmp = { -- Example
        --     -- NvimCmp... highlight groups
        --   },
        -- },
      }

      -- Example: Override specific highlight groups (like making hidden files brighter)
      local custom_highlight_overrides = {
        -- Make hidden files brighter (confirm group name with :Inspect in your file explorer!)
        MiniFilesHidden = { fg = "#70788c" }, -- Example for mini.files + palenight style (adjust color)
        NvimTreeHiddenFile = { fg = "#70788c" }, -- Example for nvim-tree + palenight style (adjust color)
        NeoTreeHiddenFile = { fg = "#70788c" }, -- Example for neo-tree + palenight style (adjust color)

        -- Make comments italic (if not default)
        Comment = { italic = true },

        -- Add any other highlight group overrides here
        -- String = { fg = "#C3E88D" }, -- Example override for strings in palenight
      }

      -- Example: Override base palette colors (advanced)
      local custom_colors_overrides = {
        -- Example: Change the main background color slightly
        -- bg_default = "#282A36", -- Example color (Dracula-like)
      }

      -- Return the options table for material.nvim
      return {
        -- Available styles: 'darker', 'palenight', 'oceanic', 'lighter', 'deep ocean'
        style = style,

        -- Italics configuration
        italic_comments = false,
        italic_keywords = false,
        italic_functions = false,
        italic_variables = false,

        -- Disable specific features if needed
        disable = disable,

        -- Configure plugin integrations
        plugins = plugins,

        -- Apply custom highlight group overrides
        custom_highlight_overrides = custom_highlight_overrides,

        -- Apply custom base color palette overrides (use with caution)
        custom_colors_overrides = custom_colors_overrides,
      }
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      transparent_background = true,
      variant = "main",

      setmetatableyles = {
        bold = true,
        italic = false,
      },
    },
    lazy = true,
  },
  -- set LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material",
      --colorscheme = "catppuccin-mocha",
      --colorscheme = "catppuccin-macchiato",
      --forcolorscheme = "adwaita",
      --colorscheme = "rose-pine-dawn",
    },
  },
}
