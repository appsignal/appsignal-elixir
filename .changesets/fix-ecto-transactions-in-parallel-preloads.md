---
bump: patch
type: fix
---

Fix an issue where Ecto transactions in parallel preloads would not be instrumented correctly when using `Appsignal.Ecto.Repo`, causing the query in the Ecto transaction to not be instrumented and the sample to be incorrectly closed as an earlier time.
