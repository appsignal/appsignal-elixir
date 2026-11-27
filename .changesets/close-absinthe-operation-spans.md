---
bump: patch
type: fix
---

Close the span of an Absinthe operation, and any span left open inside it, when the operation ends. A span a resolver left open was closed in place of the operation's span, which was never reported.
