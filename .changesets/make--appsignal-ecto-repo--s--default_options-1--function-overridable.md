---
bump: patch
type: fix
---

Make `Appsignal.Ecto.Repo`'s `default_options/1` function overridable. If your Ecto repo uses `Appsignal.Ecto.Repo` and implements its own `default_options/1`, it must call `super` to merge its default options with those of `Appsignal.Ecto.Repo`:

```elixir
defmodule MyEctoRepo
  use Appsignal.Ecto.Repo

  def default_options(operation) do
    super(operation) ++ [
      # ... your default options here ...
    ]
  end
end
```
