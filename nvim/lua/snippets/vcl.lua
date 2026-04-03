return {
  s("vcl", {
    t({
      "vcl 4.1;",
      "",
      "backend default {",
      '  .host = "127.0.0.1";',
      '  .port = "8080";',
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
  s("backend", {
    t({ "backend " }),
    i(1, "name"),
    t({ " {", '    .host = "' }),
    i(2, "127.0.0.1"),
    t({ '";', '    .port = "' }),
    i(3, "8080"),
    t({ '";', "}" }),
  }),
  s("acl", {
    t({ "acl " }),
    i(1, "name"),
    t({ " {", '    "' }),
    i(2, "localhost"),
    t({ '";', '    "' }),
    i(3, "192.168.0.0/24"),
    t({ '";', "}" }),
  }),
  s("if", {
    t({ "if (" }),
    i(1, 'req.url ~ "^/admin"'),
    t({ ") {", "    " }),
    i(2, "return (pass);"),
    t({ "", "}" }),
  }),
  s("req.http", {
    t({ "req.http." }),
    i(1, "Header-Name"),
  }),
  s("beresp.http", {
    t({ "beresp.http." }),
    i(1, "Header-Name"),
  }),
  s("obj.http", {
    t({ "obj.http." }),
    i(1, "Header-Name"),
  }),
  s("return", {
    t({ "return (" }),
    i(1, "pass"),
    t({ ");" }),
  }),
  s("unset", {
    t({ "unset " }),
    i(1, "req.http.Cookie"),
    t({ ";" }),
  }),
  s("set", {
    t({ "set " }),
    i(1, "req.http.X-Custom"),
    t({ ' = "' }),
    i(2, "value"),
    t({ '";' }),
  }),
  s("synth", {
    t({ "return (synth(" }),
    i(1, "403"),
    t({ ', "' }),
    i(2, "Access Denied"),
    t({ '"));' }),
  }),
}
