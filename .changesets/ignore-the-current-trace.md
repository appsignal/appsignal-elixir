---
bump: major
type: change
---

Change `Appsignal.Tracer.ignore/0` to ignore the current trace: the trace the current span belongs to is not reported. It no longer stops the process from creating spans for the rest of its life, and it does nothing when there is no current span. `Appsignal.Tracer.ignore/1` no longer does anything and is deprecated. The integrations no longer ignore a process after reporting an error, so a process that keeps running after an error, such as a Bandit connection that serves another request, stays instrumented.
