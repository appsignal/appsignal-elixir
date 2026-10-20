---
bump: major
type: change
---

Remove the optional dependencies on HTTPoison, Plug, Phoenix and Phoenix LiveView, so that AppSignal for Elixir can be installed alongside any version of them. The HTTPoison, Plug and Phoenix integrations are always compiled, so an umbrella application no longer needs AppSignal recompiled to instrument them.
