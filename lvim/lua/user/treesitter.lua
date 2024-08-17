-- ~/.config/lvim/lua/user/treesitter.lua

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "rust", "python", "bash", "lua", "json", "yaml" },
  highlight = { enable = true },
  indent = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
}
