---
bump: patch
type: change
---

`Appsignal.Tracer.root_span/0` now always returns the root span of the trace that the current span belongs to.

When the current span is part of a trace that was opened while another trace was current, data set on the root span and errors reported with `Appsignal.set_error/2,3` are now reported on the newly opened trace's root span, rather than on the root span of the previous trace.

Code that intends to set data on the previously existing trace after creating a root span should keep a reference to the outer root span to do so.
