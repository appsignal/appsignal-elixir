---
bump: patch
type: fix
---

Name a Phoenix request that fails with a `Phoenix.ActionClauseError` after its controller and action, as `MyAppWeb.PageController#show`, like the requests to that action that succeed. These requests were named `Elixir.MyAppWeb.PageController#show`, so AppSignal reported them as a separate action.
