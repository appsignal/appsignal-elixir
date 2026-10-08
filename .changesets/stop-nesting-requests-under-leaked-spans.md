---
bump: patch
type: fix
---

Fixed an issue where, if a span remained open after a request to a Bandit connection, that span would become the parent of the next request on that connection.
