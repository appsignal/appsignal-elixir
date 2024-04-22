---
bump: "minor"
type: "add"
---

_Heartbeats are currently only available to beta testers. If you are interested in trying it out, [send an email to support@appsignal.com](mailto:support@appsignal.com?subject=Heartbeat%20beta)!_

---

Add heartbeats support. You can send heartbeats directly from your code, to track the execution of certain processes:

```elixir
def send_invoices do
  # ... your code here ...
  Appsignal.heartbeat("send_invoices")
end
```

You can pass a function to `Appsignal.heartbeat`, to report to AppSignal both when the process starts, and when it finishes, allowing you to see the duration of the process:

```elixir
def send_invoices do
  Appsignal.heartbeat("send_invoices", fn ->
    # ... your code here ...
  end)
end
```

If an exception is thrown within the function, the finish event will not be reported to AppSignal, triggering a notification about the missing heartbeat. The exception will bubble outside of the heartbeat function.
