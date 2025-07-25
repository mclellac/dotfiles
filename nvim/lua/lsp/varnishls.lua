return {
  -- Point to varnishls (add --debug for debug log)
  cmd = { "varnishls", "lsp", "--stdio" },
  filetypes = { "vcl", "vtc" },
  root_markers = { ".varnishls.toml", ".git" },
  settings = {},
}
