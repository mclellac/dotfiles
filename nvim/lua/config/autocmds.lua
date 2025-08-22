-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Quit Neovim if the only windows left are special ones like file explorers
local function quit_if_only_special_windows()
  local normal_window_found = false
  -- Loop through all windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype

    -- Consider a window "normal" if it has a listed buffer that is
    -- not of a special type and not the snacks plugin.
    if vim.bo[buf].buflisted and buftype == "" and filetype ~= "snacks" then
      normal_window_found = true
      break
    end
  end

  -- If no normal windows were found, it means only special windows are left.
  if not normal_window_found then
    vim.cmd("qall")
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("QuitOnLastNormalBuffer", { clear = true }),
  pattern = "*",
  callback = quit_if_only_special_windows,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.cmd("MasonUpdate")
  end,
})
