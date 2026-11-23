---
bump: patch
type: fix
---

Close the span of a Finch request when a span opened in a `Finch.stream/5` callback is left open. The left-open span was closed in its place, and the request's span was never reported.
