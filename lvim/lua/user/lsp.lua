-- ~/.config/lvim/lua/user/lsp.lua
require("lvim.lsp.manager").setup("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "strict",  -- Enable strict mode for better type checking
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
    on_attach = function(client, bufnr)
        require("lvim.lsp").common_on_attach(client, bufnr)
    end,
})

lvim.builtin.which_key.mappings["m"] = {
    name = "Python",
    i = { "<cmd>PyrightOrganizeImports<CR>", "Organize Imports" },
    r = { "<cmd>PyrightRename<CR>", "Rename Symbol" },
}
