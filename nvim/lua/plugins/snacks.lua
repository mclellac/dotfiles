return {
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = false },
      input = { enabled = true },
      picker = {
        hidden = true, -- for hidden files
        ignored = true, -- for .gitignore files
        sources = {
          explorer = {
            layout = { layout = { position = "left" } },
            follow_file = true,
            tree = true,
            focus = "list",
            auto_close = true,
          },
        },
      },
    },
  },

  -- Added noice.nvim for better UI notifications and command line
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- You can customize noice.nvim options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-dap-ui", -- For better DAP notifications if you use nvim-dap
    },
  },

  -- Added dressing.nvim for enhanced vim.ui.select and vim.ui.input
  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("dressing").select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("dressing").input(...)
      end
    end,
  },
}