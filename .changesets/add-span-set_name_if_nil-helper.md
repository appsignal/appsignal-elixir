---
bump: patch
type: add
---

Add `Appsignal.Span.set_name_if_nil` helper. This helper can be used to not overwrite previously set span names, and only set the span name if it wasn't set previously. This will used most commonly in AppSignal created integrations with other libraries to allow apps to set custom span names.
