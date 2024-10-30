--- Check if it's weekend
---@return boolean
local function is_weekend()
  local day = tonumber(os.date("%w"))
  return day == 0 or day == 6
end

--- Check if it's day time
---@return boolean
local function is_day_time()
  local hour = tonumber(os.date("%H"))
  return hour >= 9 and hour < 19
end

local is_transparent = is_day_time() and not is_weekend()

--- Check if it's WarpTerminal
---@return boolean
local function is_warp_terminal()
  return os.getenv("TERM_PROGRAM") == "WarpTerminal"
end

-- Default colorscheme
local default_color_scheme = "rose-pine-dawn"

-- Select colorscheme based on the time, and load it with LazyVim
local function selectColorSchemeByTime()
  -- skip if running in vscode
  if vim.g.vscode then
    return "material"
  end

  if vim.g.neovide then
    return "nightfox"
  end

  if is_warp_terminal() then
    return "cobalt2"
  end

  if is_transparent then
    return default_color_scheme
  else
    local night_themes = {
      "tokyonight",
      "material",
      "nightfox",
      "rose-pine",
      "catppuccin-frappe",
      "everforest",
      "dracula",
      "kanagawa",
      "nord",
      "cobalt2",
    }
    local idx = tonumber(os.date("%S")) % #night_themes + 1

    local colorscheme = night_themes[idx]
    vim.notify("Selected colorscheme: " .. colorscheme)
    return colorscheme
  end
end

--- Set random colorscheme with turning off transparent background
local function randomize_theme()
  is_transparent = false
  local colorscheme = selectColorSchemeByTime()
  vim.cmd.colorscheme(colorscheme)
end

-- Define a keymap to randomize colorscheme
vim.keymap.set("n", "<leader>tc", randomize_theme, {
  desc = "Randomize colorscheme",
})

return {
  {
    "EdenEast/nightfox.nvim",
    opts = {
      options = {
        transparent = is_transparent,
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
    },
    lazy = true,
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
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      transparent_background = is_transparent,
    },
  },
  {
    "sainnhe/everforest",
    config = function()
      -- " Available values: 'hard', 'medium'(default), 'soft'
      if is_transparent then
        vim.g.everforest_background = "soft"
        vim.g.everforest_transparent_background = 1
      end
      -- For better performance
      vim.g.everforest_better_performance = 1
      -- Enable italic
      vim.g.everforest_enable_italic = 1
    end,
    lazy = true,
  },
  {
    "Mofiqul/dracula.nvim",
    opts = {
      transparent_bg = is_transparent,
      show_end_of_buffer = true,
      -- set italic comment
      italic_comment = true,
    },
    config = function(_, opts)
      local dracula = require("dracula")
      dracula.setup(opts)
      -- Disable spell check as it's too red
      vim.o.spell = false
    end,
    lazy = true,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      -- Remove gutter background
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Transparent background
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },

          -- Borderless telescope
          TelescopeTitle = { fg = theme.ui.special, bold = true },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
          TelescopePreviewNormal = { bg = theme.ui.bg_dim },
          TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
        }
      end,
    },
  },
  {
    "shaunsingh/nord.nvim",
    opts = {
      markdown = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        quote_highlight = "Quote",
      },
    },
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = false
      vim.g.nord_disable_background = is_transparent
      vim.g.nord_italic = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = false
    end,
    lazy = true,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = is_transparent,
      styles = is_transparent and {
        sidebars = "transparent",
        floats = "transparent",
      } or {},
    },
  },
  -- set LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = selectColorSchemeByTime(),
    },
  },
}
