---
bump: patch
type: fix
---

Fixed an issue where the LiveView integration left a LiveView or LiveComponent event's span open, so its trace and error were not reported. This happened when another span opened during the event was still open, such as one from `Appsignal.instrument/2`, which was closed instead, and when the event was also instrumented with `Appsignal.Phoenix.LiveView.instrument/5` and raised.
