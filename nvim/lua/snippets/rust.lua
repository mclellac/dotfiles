return {
  s("main", {
    t({
      "fn main() {",
      "  println!(\"Hello, world!\");",
      "}",
    }),
  }),
  s("test", {
    t({
      "#[cfg(test)]",
      "mod tests {",
      "  use super::*;",
      "",
      "  #[test]",
      "  fn it_works() {",
      "    assert_eq!(2 + 2, 4);",
      "  }",
      "}",
    }),
  }),
}
