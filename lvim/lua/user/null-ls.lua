-- ~/.config/lvim/lua/user/null-ls.lua
local null_ls = require("null-ls")

null_ls.setup({
  debug = true,
  sources = {
    null_ls.builtins.diagnostics.ruff.with({ -- Customize settings
      extra_args = { "--max-line-length", "100" },
    }),
    null_ls.builtins.formatting.ruff,
    -- null_ls.builtins.formatting.isort,
    -- null_ls.builtins.formatting.black.with({ extra_args = { "--fast" }}),
    null_ls.builtins.formatting.rustfmt,
    -- null_ls.builtins.diagnostics.clippy,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.diagnostics.clang_check,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.yamllint,
    null_ls.builtins.formatting.prettier.with({
      extra_filetypes = { "toml" },
    }),
  },
})
