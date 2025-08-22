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
  -- Loop through all windows to check if any are "normal"
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        local buflisted = vim.api.nvim_buf_get_option(buf, "buflisted")
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

        -- A "normal" window is one with a listed buffer, no special buftype,
        -- and not a known special filetype like snacks or the dashboard.
        if buflisted and buftype == "" and filetype ~= "snacks" and filetype ~= "dashboard" then
          -- Found a normal window, so we do nothing and exit the function.
          return
        end
      end
    end
  end

  -- If the loop completes, no normal windows were found.
  -- Defer the quit command to avoid race conditions with other autocommands.
  vim.defer_fn(function()
    vim.cmd("qall")
  end, 10)
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
