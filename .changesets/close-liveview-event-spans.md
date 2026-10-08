---
bump: patch
type: fix
---

Fixed an issue where a LiveView or LiveComponent event's span was left open, without its error, when the event was instrumented with `Appsignal.Phoenix.LiveView.instrument/5` and the instrumented function raised.
