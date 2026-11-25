---
bump: patch
type: fix
---

Prevent the error backend from reporting an error that was already reported by `Appsignal.set_error/2,3`, `Appsignal.Span.add_error/3,4`, or by a language or framework integration.
