-- ~/.config/lvim/lua/user/mason.lua
require("mason").setup()

-- Setup Mason LSPConfig
require("mason-lspconfig").setup({
  ensure_installed = {
    "bashls",
    "clangd",
    "rust_analyzer",
    -- "pyright",
    "ruff-lsp",
  },
})

-- Setup Mason null-ls
require("mason-null-ls").setup({
  ensure_installed = {
    "shellcheck",
    "shfmt",
    "black",
    "isort",
    "rustfmt",
    "ruff",
  },
})

-- Setup Mason nvim-dap
require("mason-nvim-dap").setup({
  ensure_installed = {
    "codelldb",
    "python",
  },
})
