-- config.lua

-- Reload user-defined configurations
reload "user.plugins"
reload "user.options"
reload "user.nvimtree"
reload "user.null-ls"
reload "user.treesitter"
reload "user.telescope"

-- Install and setup Mason
-- require("mason").setup()

-- Automatically install LSP servers, formatters, linters, and DAP servers
-- require("user.mason")

-- Add `pyright` to `skipped_servers` list as we will use ruff/ruff_ls
--vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

-- Ensure system tools are installed
-- require("user.tools")
