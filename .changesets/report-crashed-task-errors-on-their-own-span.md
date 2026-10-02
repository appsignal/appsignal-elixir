---
bump: patch
type: fix
---

Fixed an issue where, with the error backend enabled, the error of a process that crashed after attaching another process's span with `Appsignal.Tracer.register_current/1` was reported on that other process's span, which was then closed, so the rest of that process's trace was not reported. The error is now reported on the crashed process's own span, or on a new sample when it has none.
