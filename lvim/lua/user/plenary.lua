-- ~/.config/lvim/lua/user/plenary.lua

-- Typically, plenary doesn't require explicit setup.
-- You might include any utility functions or custom commands that depend on plenary here.

-- Example: a simple reload function
function ReloadConfig()
    for name,_ in pairs(package.loaded) do
      if name:match('^user') then
        package.loaded[name] = nil
      end
    end
    dofile(vim.env.MYVIMRC)
  end
  
  vim.api.nvim_set_keymap('n', '<Leader>r', ':lua ReloadConfig()<CR>', { noremap = true, silent = true })
  