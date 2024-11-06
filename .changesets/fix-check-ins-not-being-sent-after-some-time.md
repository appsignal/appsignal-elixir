---
bump: patch
type: fix
---

Fix an issue where, after a certain amount of time, check-ins would no longer be sent.

This issue also caused the default Hackney connection pool to be saturated, affecting other code that uses the default Hackney connection pool.
