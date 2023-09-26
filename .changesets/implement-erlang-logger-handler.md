---
bump: "patch"
type: "add"
---

Implement an Erlang :logger handler for sending logs from AppSignal, in
preparation for the eventual deprecation of Elixir logger backends.

Add a convenience method to configure this logger handler automatically,
with the right settings for AppSignal:

```elixir
Appsignal.Logger.Handler.add("my_app", :plaintext)
```

To remove the logging handler, call the `.remove` method:

```elixir
Appsignal.Logger.Handler.remove()
```
