-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 80 char width lines are ridiculous
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Settings for both Nvim-qt and Neovide
local font_name = "JetBrainsMono Nerd Font"
local font_size = 12 -- Adjust as needed

-- Nvim-qt specific settings
if vim.g.GuiLoaded then
  local not_transparent = false

  local function toggle_transparency()
    not_transparent = not not_transparent
    vim.cmd("GuiWindowOpacity " .. (not_transparent and 0.9 or 1.0))
  end

  vim.keymap.set("n", "<F10>", toggle_transparency, { silent = true })

  local function toggle_fullscreen()
    vim.cmd("call GuiWindowFullScreen(" .. (vim.g.GuiWindowFullScreen == 0 and 1 or 0) .. ")")
  end

  vim.keymap.set("n", "<F11>", toggle_fullscreen, { silent = true })

  vim.cmd([[
    GuiTabline 0
    GuiPopupmenu 0
  ]])
  vim.cmd("GuiFont! " .. font_name .. ":h" .. font_size)
end

-- Neovide specific settings
if vim.g.neovide then
  print("neovide settings from init.lua loaded")
  vim.o.guifont = font_name .. ":h" .. font_size -- Use vim.o for options
  vim.g.neovide_remember_window_size = true -- Updated option name
  vim.g.neovide_remember_window_position = true -- Updated option name
  vim.g.neovide_scale_factor = 1.2
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_vfx_mode = "torpedo"
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.g.neovide_hide_mouse_when_typing = true

  local function toggle_transparency()
    vim.g.neovide_transparency = vim.g.neovide_transparency == 1.0 and 0.8 or 1.0
  end

  local function toggle_fullscreen()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end

  vim.keymap.set("n", "<F11>", toggle_fullscreen, { silent = true })
  vim.keymap.set("n", "<F10>", toggle_transparency, { silent = true })
end
