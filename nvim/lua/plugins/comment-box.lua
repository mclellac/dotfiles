return {
  {
    "LudoPinelli/comment-box.nvim",
    -- event = "VeryLazy", -- Or other event if you want to load it later
    config = function()
      require("comment-box").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
    keys = {
      { "<leader>acb", "<cmd>CommentBox<cr>", desc = "Add Comment Box" },
    },
  },
}
