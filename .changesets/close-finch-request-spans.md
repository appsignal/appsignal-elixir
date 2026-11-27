---
bump: patch
type: fix
---

Close the span of a Finch request, and any span left open inside it, when the request ends. A span opened in a `Finch.stream/5` callback and left open was closed in place of the request's span, which was never reported.
