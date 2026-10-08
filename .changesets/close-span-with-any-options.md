---
bump: patch
type: fix
---

Accept any keyword list of options in `Appsignal.Tracer.close_span/2`, using its `:end_time` when present. An empty list, or `:end_time` alongside another option, raised a `FunctionClauseError`.
