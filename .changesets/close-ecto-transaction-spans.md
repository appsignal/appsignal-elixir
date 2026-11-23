---
bump: patch
type: fix
---

Close the span of an Ecto transaction when code in the transaction leaves open a span it opened. The left-open span was closed in its place, with the commit or rollback inside it, and the transaction's span was never reported.
