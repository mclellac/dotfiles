-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set the background to none (transparent)
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- NOTE: GUI Options
-------------
-- Nvim-qt --
-------------

if vim.g.GuiLoaded then
  local font_name = "JetBrainsMono Nerd Font"
  local font_size = 12
  local not_transparent = false

  local function toggle_transparency()
    not_transparent = not not_transparent
    if not_transparent then
      vim.cmd("GuiWindowOpacity " .. 0.7)
    else
      vim.cmd("GuiWindowOpacity " .. 1.0)
    end
  end

  vim.keymap.set("n", "<F10>", toggle_transparency, { silent = true })

  local function toggle_fullscreen()
    if vim.g.GuiWindowFullScreen == 0 then
      vim.cmd("call GuiWindowFullScreen(" .. 1 .. ")")
    else
      vim.cmd("call GuiWindowFullScreen(" .. 0 .. ")")
    end
  end

  vim.keymap.set("n", "<F11>", toggle_fullscreen, { silent = true })

  vim.cmd([[
  GuiTabline 0
  GuiPopupmenu 0
  ]])
  vim.cmd("GuiFont! " .. font_name .. ":h" .. font_size)
end

-------------
-- Neovide --
-------------

if vim.g.neovide then
  vim.opt.guifont = "JetBrainsMono Nerd Font:h11"
  vim.g.remember_window_size = true
  vim.g.remember_window_position = true
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
    if vim.g.neovide_opacity == 1.0 then
      vim.cmd("let g:neovide_opacity=0.6")
    else
      vim.cmd("let g:neovide_opacity=1.0")
    end
  end

  local function toggle_fullscreen()
    if vim.g.neovide_fullscreen == false then
      vim.cmd("let g:neovide_fullscreen=v:true")
    else
      vim.cmd("let g:neovide_fullscreen=v:false")
    end
  end

  vim.keymap.set("n", "<F11>", toggle_fullscreen, { silent = true })
  vim.keymap.set("n", "<F10>", toggle_transparency, { silent = true })
end
