---
bump: "patch"
type: "add"
---

Add `Appsignal.Ecto.Repo` to fix parallel preloads.

For AppSignal to be able to instrument parallel preloads, the current instrumentation context needs to be passed from the Elixir process that spawns the preload to the short-lived processes that run each of the parallel queries.

By replacing `use Ecto.Repo` with `use Appsignal.Ecto.Repo`, the appropriate telemetry context will be passed so that AppSignal can correctly instrument these queries:

```elixir
defmodule MyApp.Repo do
  # replace `use Ecto.Repo` with `use Appsignal.Ecto.Repo`
  use Appsignal.Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
end
```
