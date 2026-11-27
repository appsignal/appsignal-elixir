---
bump: patch
type: fix
---

Close the span of a Tesla request, and any span left open inside it, when the request ends. A span opened by a middleware after `Tesla.Middleware.Telemetry` and left open was closed in place of the request's span, which was never reported.
