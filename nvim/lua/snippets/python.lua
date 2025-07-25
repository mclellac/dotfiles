-- For more snippets, see: https://github.com/dcampos/nvim-luasnip-python-snippets/blob/main/lua/luasnip_snippets/python/django.lua
return {
  s("pdb", {
    t("import pdb; pdb.set_trace()"),
  }),
  s("ipdb", {
    t("import ipdb; ipdb.set_trace()"),
  }),
  s("pudb", {
    t("import pudb; pudb.set_trace()"),
  }),
  s("strclass", {
    t({
      'def __str__(self):',
      '    return f"{self.}"'
    }),
  }),
  s("main", {
    t({
      'if __name__ == "__main__":',
      '    main()'
    }),
  }),
}
