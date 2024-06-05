---
bump: patch
type: change
---

Allow custom action names to be set in Phoenix routes. For example, in a plug middleware or the controller:

```elixir
Appsignal.Tracer.root_span()
|> Appsignal.Span.set_name("CustomActionName")
```
