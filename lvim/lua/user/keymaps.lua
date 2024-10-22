-- ~/.config/lvim/lua/user/keybindings.lua
lvim.builtin.which_key.mappings["t"] = {
    name = "Test",
    t = { "<cmd>lua require('neotest').run.run()<cr>", "Run Nearest Test" },
    f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run Test File" },
}

-- Python-specific keybindings
lvim.builtin.which_key.mappings["p"] = {
    name = "Python",
    e = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Python Env" },
    t = { "<cmd>lua require('neotest').run.run()<cr>", "Run Python Tests" },
    d = { "<cmd>lua require('dap-python').test_method()<cr>", "Debug Python Test" },
}
