-- TAB/INDENT ----------------------------------------------------------------
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.wrap = false

-- SEARCH --------------------------------------------------------------------
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.showmatch = true

-- APPEARANCE ----------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
--vim.opt.colorcolumn = "120"
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.scrolloff = 10
vim.opt.completeopt = "menuone,noinsert,noselect"

-- MISC ----------------------------------------------------------------------
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true
vim.opt.backspace = "indent,eol,start"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.autochdir = false
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- APPEND --------------------------------------------------------------------
vim.opt.mouse:append("a")
vim.opt.iskeyword:append("-")
vim.opt.clipboard:append("unnamedplus")

-- ANSIBLE/YAML --------------------------------------------------------------
vim.filetype.add({
  extension = {
    yml = "yaml.ansible",
  },
})

if vim.fn.has("win32") == 0 then
  vim.g.python3_host_prog = vim.fn.exepath("python3")
  vim.g.python_host_prog = vim.fn.exepath("python")
else
  vim.g.python3_host_prog = vim.fn.exepath("python.exe")
  vim.g.python_host_prog = vim.fn.exepath("python.exe")
end
