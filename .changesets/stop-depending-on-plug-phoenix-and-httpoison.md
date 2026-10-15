---
bump: major
type: change
---

Stop depending on HTTPoison, Plug, Phoenix and Phoenix LiveView, so AppSignal for Elixir installs alongside any version of them. The HTTPoison, Plug and Phoenix integrations are always part of the package and no longer depend on the order in which Mix compiles dependencies, so an umbrella application no longer needs AppSignal recompiled to instrument them.
