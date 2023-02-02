---
bump: "patch"
type: "add"
---

Add config options to disable automatic Ecto, Finch and Oban instrumentations.
Set `instrument_ecto`, `instrument_finch` or `instrument_oban` to `true` in
order to disable that instrumentation.
