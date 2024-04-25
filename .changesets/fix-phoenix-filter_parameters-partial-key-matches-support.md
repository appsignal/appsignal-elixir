---
bump: "patch"
type: "fix"
---

Fix the Phoenix `filter_parameters` config option support for partial key matches. When configuring `config :phoenix, filter_parameters` with `["key"]` or `{:discard, ["key"]}`, it now also matches partial keys like `"my_key"`, just like Phoenix's logger does.
