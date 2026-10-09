---
bump: patch
type: fix
---

Record the `result` tag as `ok` for Oban jobs that return `{:ok, value}`. These jobs had no `result` tag.
