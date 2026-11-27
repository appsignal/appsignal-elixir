---
bump: patch
type: fix
---

Close the span of a LiveView or LiveComponent event when the event leaves open a span it opened. The left-open span was closed in its place, with the event's error, and the event's span was never reported.
