return {
  s("dockerfile", {
    t({
      "FROM ",
    }),
    i(1, "ubuntu:latest"),
    t({ "", "", "WORKDIR /app", "", "COPY . .", "", "RUN " }),
    i(2, "apt-get update && apt-get install -y \\"),
    t({ "", "    " }),
    i(3, "package-name"),
    t({ "", "", 'CMD ["' }),
    i(4, "executable"),
    t({ '"]' }),
  }),
  s("from", {
    t({ "FROM " }),
    i(1, "image"),
    t({ ":" }),
    i(2, "tag"),
  }),
  s("workdir", {
    t({ "WORKDIR " }),
    i(1, "/path"),
  }),
  s("copy", {
    t({ "COPY " }),
    i(1, "src"),
    t({ " " }),
    i(2, "dest"),
  }),
  s("run", {
    t({ "RUN " }),
    i(1, "command"),
  }),
  s("cmd", {
    t({ 'CMD ["' }),
    i(1, "executable"),
    t({ '", "' }),
    i(2, "param1"),
    t({ '"]' }),
  }),
  s("entrypoint", {
    t({ 'ENTRYPOINT ["' }),
    i(1, "executable"),
    t({ '", "' }),
    i(2, "param1"),
    t({ '"]' }),
  }),
  s("env", {
    t({ "ENV " }),
    i(1, "KEY"),
    t({ '="' }),
    i(2, "value"),
    t({ '"' }),
  }),
  s("expose", {
    t({ "EXPOSE " }),
    i(1, "8080"),
  }),
  s("arg", {
    t({ "ARG " }),
    i(1, "NAME"),
    t({ "=" }),
    i(2, "default_value"),
  }),
  s("volume", {
    t({ 'VOLUME ["' }),
    i(1, "/data"),
    t({ '"]' }),
  }),
  s("user", {
    t({ "USER " }),
    i(1, "username"),
  }),
}
