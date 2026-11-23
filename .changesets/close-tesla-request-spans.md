---
bump: patch
type: fix
---

Close the span of a Tesla request when a span opened by a middleware after `Tesla.Middleware.Telemetry` is left open. The left-open span was closed in its place, and the request's span was never reported.
