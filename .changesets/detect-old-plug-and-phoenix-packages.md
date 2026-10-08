---
bump: major
type: change
---

Disable AppSignal on start, and log an error explaining how to fix it, when `appsignal_plug` or `appsignal_phoenix` before 3.0.0 is installed alongside AppSignal for Elixir 3.0. Those packages define the same modules as this one, and loading both breaks the instrumentation. Remove them from your application's dependencies, along with any `override: true` on `appsignal`.

Log a warning on start when Plug or Phoenix is loaded but AppSignal was compiled without its integration, which can happen in an umbrella application when a child without Phoenix is compiled first. Run `mix deps.compile appsignal --force` to fix it.
