---
bump: patch
type: fix
---

With the error backend enabled, stop reporting a crash a second time when its error was already reported, for example with `Appsignal.set_error/2,3`, `Appsignal.Span.add_error/3,4` or one of the integrations.
