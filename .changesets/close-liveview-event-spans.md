---
bump: patch
type: fix
---

Fix the LiveView integration closing the wrong span when another span was opened during a LiveView or LiveComponent event and was still open, for example by `Appsignal.instrument/2`. It closed that span instead of the event's, and could add the event's error to it. The event's span stayed open, so its trace and error were not reported.
