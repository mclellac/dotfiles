-- Additional Plugins
lvim.plugins = {
  { "folke/trouble.nvim" },
  { "theprimeagen/harpoon" },
  { "CRAG666/code_runner.nvim" },
  { "mg979/vim-visual-multi", branch = "master" },
  { "mfussenegger/nvim-dap" },
  { "mfussenegger/nvim-dap-python" },
  { "AckslD/swenv.nvim" },
  { "rose-pine/neovim" },
  { "nordtheme/vim" },
  { "folke/todo-comments.nvim" },
  {
    "s1n7ax/nvim-window-picker",
    version = "v1.*",
    config = function()
      require("window-picker").setup()
    end,
  },
  "nvim-neotest/nvim-nio",
  "varnishcache-friends/vim-varnish",
  {
    "mawkler/modicator.nvim",
    event = "ColorScheme",
  },
  "HiPhish/rainbow-delimiters.nvim",
  "andymass/vim-matchup",
  "lunarvim/synthwave84.nvim",
  {
    "kndndrj/nvim-dbee",
    build = function()
      require("dbee").install()
    end,
  },
  "kkharji/sqlite.lua",
  "stevearc/dressing.nvim",
  "roobert/tailwindcss-colorizer-cmp.nvim",
  -- "nvim-treesitter/playground",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "mfussenegger/nvim-jdtls",
  "opalmay/vim-smoothie",
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
  },
  "windwp/nvim-ts-autotag",
  "kylechui/nvim-surround",
  "NvChad/nvim-colorizer.lua",
  "moll/vim-bbye",
  "windwp/nvim-spectre",
  "f-person/git-blame.nvim",
  "ruifm/gitlinker.nvim",
  "mattn/vim-gist",
  "mattn/webapi-vim",
  "folke/zen-mode.nvim",
  {
    "lvimuser/lsp-inlayhints.nvim",
    branch = "anticonceal",
  },
  "lunarvim/darkplus.nvim",
  "kevinhwang91/nvim-bqf",
  "is0n/jaq-nvim",
  "nacro90/numb.nvim",
  "neogitorg/neogit",
  "sindrets/diffview.nvim",
  "simrat39/rust-tools.nvim",
  "olexsmir/gopher.nvim",
  "leoluz/nvim-dap-go",
  "jose-elias-alvarez/typescript.nvim",
  "mxsdev/nvim-dap-vscode-js",
  "petertriho/nvim-scrollbar",
  -- "renerocksai/calendar-vim",
  {
    "saecki/crates.nvim",
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup {
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      }
    end,
  },
  "MunifTanjim/nui.nvim",
  "jackMort/ChatGPT.nvim",
  {
    "jinh0/eyeliner.nvim",
    config = function()
      require("eyeliner").setup {
        highlight_on_key = true,
      }
    end,
  },
  { "christianchiarulli/telescope-tabs", branch = "chris" },
  "monaqa/dial.nvim",
  {
    "0x100101/lab.nvim",
    build = "cd js && npm ci",
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  -- {
  --   "tzachar/cmp-tabnine",
  --   event = "BufRead",
  --   build = "./install.sh",
  -- },

  "MunifTanjim/nui.nvim",
  "Bryley/neoai.nvim",
  "nvim-neotest/neotest",
  "nvim-neotest/neotest-python",
  {
    "hrsh7th/cmp-emoji",
    event = "BufRead",
  },
  "ThePrimeagen/vim-be-good",
  -- "folke/noice.nvim",
  -- "rcarriga/nvim-notify",

  -- https://github.com/jose-elias-alvarez/typescript.nvim
  -- "rmagatti/auto-session",
  -- "rmagatti/session-lens"
  -- "christianchiarulli/nvim-ts-rainbow",
  -- "karb94/neoscroll.nvim",
}
