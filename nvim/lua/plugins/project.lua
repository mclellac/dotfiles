return {
  "ahmedkhalf/project.nvim",
  -- Explicitly setting opts to ensure our patterns are used for basic testing
  opts = {
    -- Simplified patterns for basic detection testing
    patterns = { ".git", "Makefile", "package.json", "go.mod" },
    detection_methods = { "lsp", "pattern", "parent" }, -- Ensure these are still enabled
    show_hidden = false,
    show_on_start = false,
    datapath = vim.fn.stdpath("data") .. "/site/projects",
  },
  keys = {
    { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find Project" },
  },
}