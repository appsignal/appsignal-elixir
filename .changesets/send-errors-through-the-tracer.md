---
bump: minor
type: change
---

The function passed to `Appsignal.send_error/3,4` now runs with the error's span as the current span. Calls such as `Appsignal.Span.set_sample_data/3` on `Appsignal.Tracer.current_span/0` or `Appsignal.Tracer.root_span/0` inside that function now apply to the error's span, instead of to the span that was current before `send_error` was called.
