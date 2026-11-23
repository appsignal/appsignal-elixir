---
bump: patch
type: fix
---

Close the span of an Absinthe operation when a resolver leaves open a span it opened. The left-open span was closed in its place, and the operation's span was never reported.
