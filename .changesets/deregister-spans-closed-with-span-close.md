---
bump: patch
type: fix
---

Stop treating a span closed with `Appsignal.Span.close/1` or `Appsignal.Span.close/2` as the current or root span of its process. New spans created after this span has been closed will no longer be children of this span.
