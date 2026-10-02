---
bump: minor
type: change
---

`Appsignal.Tracer.root_span/0` now returns the root span of the trace the current span belongs to. Inside a root span opened within another trace, such as a function decorated with `transaction()`, a span created with `Appsignal.Tracer.create_span/1`, a LiveView mount during a request or a Broadway message, data set on the root span and errors reported with `Appsignal.set_error/2,3` are now reported on that trace's sample, rather than on the first span opened in the process. From another process working under a span, such as a task created with a parent span or one that called `Appsignal.Tracer.register_current/1`, it returns the root span of the trace that span belongs to, so data set there is reported on the trace's own sample. Code that sets data on the outer trace from inside such a root span should keep a reference to the outer root span instead.
