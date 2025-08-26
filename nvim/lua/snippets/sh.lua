return {
  s("shebang", {
    t({
      "#!/bin/bash",
      "set -euo pipefail",
      "IFS=$'\\n\\t'",
    }),
  }),
  s("main", {
    t({
      "main() {",
      "  ",
      "}",
      "",
      "main \"$@\"",
    }),
  }),
}
