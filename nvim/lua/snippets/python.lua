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
  s("class", {
    t({
      "class ",
      i(1, "ClassName"),
      "(",
      i(2, "object"),
      "):",
      "",
      "    def __init__(self, ",
      i(3, "args"),
      "):",
      "        ",
      i(4, "pass"),
    }),
  }),
  s("def", {
    t({
      "def ",
      i(1, "function_name"),
      "(",
      i(2, "args"),
      "):",
      "    ",
      i(3, "pass"),
    }),
  }),
  s("for", {
    t({
      "for ",
      i(1, "item"),
      " in ",
      i(2, "iterable"),
      ":",
      "    ",
      i(3, "pass"),
    }),
  }),
  s("if", {
    t({
      "if ",
      i(1, "condition"),
      ":",
      "    ",
      i(2, "pass"),
    }),
  }),
  s("while", {
    t({
      "while ",
      i(1, "condition"),
      ":",
      "    ",
      i(2, "pass"),
    }),
  }),
  s("import", {
    t({
      "import ",
      i(1, "module"),
    }),
  }),
  s("from", {
    t({
      "from ",
      i(1, "module"),
      " import ",
      i(2, "name"),
    }),
  }),
}
