---
bump: patch
type: fix
---

With the error backend enabled, report the crash of a process that registered another process's span with `Appsignal.Tracer.register_current/1` on that process's own span, or on a new sample when it has none. The other process's span is no longer closed by the crash, so the rest of its trace is still reported.
