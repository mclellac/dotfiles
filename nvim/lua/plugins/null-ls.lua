-- ~/.config/nvim/lua/plugins/null-ls.lua

return {
  "jose-elias-alvarez/null-ls.nvim",
  ft = { "yaml", "ansible", "python", "go", "rust" },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        -- YAML and Ansible
        null_ls.builtins.formatting.yamlfmt,
        null_ls.builtins.diagnostics.ansiblelint.with({
          extra_args = { "--format", "compact" },
        }),

        -- Python
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.flake8,

        -- Go
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.diagnostics.golangci_lint,

        -- Rust
        null_ls.builtins.formatting.rustfmt,
        null_ls.builtins.diagnostics.clippy,
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
