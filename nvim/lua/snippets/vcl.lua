return {
  s("vcl", {
    t({
      "vcl 4.1;",
      "",
      "backend default {",
      "  .host = \"127.0.0.1\";",
      "  .port = \"8080\";",
      "}",
    }),
  }),
  s("recv", {
    t({
      "sub vcl_recv {",
      "  ",
      "}",
    }),
  }),
  s("hit", {
    t({
      "sub vcl_hit {",
      "  ",
      "}",
    }),
  }),
  s("miss", {
    t({
      "sub vcl_miss {",
      "  ",
      "}",
    }),
  }),
  s("pass", {
    t({
      "sub vcl_pass {",
      "  ",
      "}",
    }),
  }),
  s("fetch", {
    t({
      "sub vcl_fetch {",
      "  ",
      "}",
    }),
  }),
  s("deliver", {
    t({
      "sub vcl_deliver {",
      "  ",
      "}",
    }),
  }),
}
