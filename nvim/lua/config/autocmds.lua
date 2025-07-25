-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
    if buftype == "nofile" then
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match("snacks") then
        local bufnrs = vim.api.nvim_list_bufs()
        local has_other_buffer = false
        for _, b in ipairs(bufnrs) do
          if b ~= bufnr and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
            has_other_buffer = true
            break
          end
        end
        if not has_other_buffer then
          vim.cmd("q")
        end
      end
    end
  end,
})
