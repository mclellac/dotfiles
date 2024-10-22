local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

require("null-ls").setup({
    sources = {
        -- Formatters
        formatting.black.with({ extra_args = { "--fast", "--line-length", "120" } }),  -- Set line length to 120
        formatting.isort,  -- Sort imports with isort

        -- Linters
        diagnostics.flake8.with({ extra_args = { "--max-line-length", "120" } }),  -- Lint with flake8 with line length 120
        diagnostics.pydocstyle.with({ extra_args = { "--ignore", "D203" } }),  -- Lint with pydocstyle
        diagnostics.ruff,  -- Add Ruff as a linter
    },
})
