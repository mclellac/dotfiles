-- config.lua
local lspconfig = require('lspconfig')

lspconfig.ruff_lsp.setup({
  on_attach = function(client, bufnr)
    -- Customize on_attach if needed
  end,
  settings = {
    -- Add any ruff-specific settings if necessary
  },
})
