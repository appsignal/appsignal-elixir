---
bump: patch
type: fix
---

Close instrumentation spans when an error occurs inside the `Appsignal.instrument` helper's function argument. This prevents spans and traces from not being closed properly.

This will no longer fail to close spans:

```elixir
Appsignal.instrument("event name", fn -> do
  raise "Oh no!"
end)
```
