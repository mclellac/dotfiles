return {
  -- Adds integration with the Lazygit TUI application
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitGarbageCollect",
      "LazyGitLog",
      "LazyGitPopup",
      "LazyGitRoot",
    },
    -- Change the following in `lua/config/keymaps.lua` to map it
    -- { "<leader>lg", "<cmd>LazyGit<CR>", desc = "Lazygit" },
  },
}