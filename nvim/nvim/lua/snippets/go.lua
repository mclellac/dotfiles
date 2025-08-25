return {
  s("main", {
    t({
      "package main",
      "",
      "import \"fmt\"",
      "",
      "func main() {",
      "  fmt.Println(\"Hello, world\")",
      "}",
    }),
  }),
  s("err", {
    t({
      "if err != nil {",
      "  return err",
      "}",
    }),
  }),
}
