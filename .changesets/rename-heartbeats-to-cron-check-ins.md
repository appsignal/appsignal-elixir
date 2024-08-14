---
bump: patch
type: change
---

Rename heartbeats to cron check-ins. Calls to `Appsignal.heartbeat` and `Appsignal.Heartbeat` should be replaced with calls to `Appsignal.CheckIn.cron` and `Appsignal.CheckIn.Cron`, for example:

```elixir
# Before
Appsignal.heartbeat("do_something", fn ->
  do_something()
end)

# After
Appsignal.CheckIn.cron("do_something", fn ->
  do_something
end)
```
