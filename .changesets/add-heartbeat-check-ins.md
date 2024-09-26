---
bump: minor
type: add
---

Add support for heartbeat check-ins.

Use the `Appsignal.CheckIn.heartbeat` method to send a single heartbeat check-in event from your application. This can be used, for example, in a `GenServer`'s callback:

```elixir
@impl true
def handle_cast({:process_job, job}, jobs) do
  Appsignal.CheckIn.heartbeat("job_processor")
  {:noreply, [job | jobs], {:continue, :process_job}}
end
```

Heartbeats are deduplicated and sent asynchronously, without blocking the current thread. Regardless of how often the `.heartbeat` method is called, at most one heartbeat with the same identifier will be sent every ten seconds.

Pass `continuous: true` as the second argument to send heartbeats continuously during the entire lifetime of the current process. This can be used, for example, during a `GenServer`'s initialisation:

```elixir
@impl true
def init(_arg) do
  Appsignal.CheckIn.heartbeat("my_genserver", continuous: true)
  {:ok, nil}
end
```

You can also use `Appsignal.CheckIn.Heartbeat` as a supervisor's child process, in order for heartbeats to be sent continuously during the lifetime of the supervisor. This can be used, for example, during an `Application`'s start:

```elixir
@impl true
def start(_type, _args) do
  Supervisor.start_link([
    {Appsignal.CheckIn.Heartbeat, "my_application"}
  ], strategy: :one_for_one, name: MyApplication.Supervisor)
end
```
