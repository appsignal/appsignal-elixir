---
bump: minor
type: change
---

Change `Appsignal.Tracer.ignore/0` to only ignore the current trace. Before this change, `Appsignal.Tracer.ignore/0` would prevent any span operations for the entire life of the current process, effectively abandoning the current trace.

`Appsignal.Tracer.ignore/1` no longer does anything and is deprecated.
