---
bump: patch
type: fix
---

Stop treating a span closed with `Appsignal.Span.close/1` or `Appsignal.Span.close/2` as the current or root span of its process. Spans created after it are no longer nested under a span that has already ended.
