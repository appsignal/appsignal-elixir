---
bump: "patch"
type: "add"
---

Set data on spans with the `custom_on_create_fun` hook. This hook is called upon the creation of every span. This can be useful to add tags to internal traces and otherwise difficult to access traces.

This won't be necessary for most scenarios. We recommend following [our tagging guide](https://docs.appsignal.com/guides/custom-data/tagging-request.html#elixir) instead.

```elixir
defmodule MyApp.Appsignal do
  def custom_on_create_fun(_span) do
    Appsignal.Span.set_sample_data(Appsignal.Tracer.root_span, "tags", %{"locale": "en"})
  end
end
```

```elixir
# config/config.exs
config :appsignal, custom_on_create_fun: &MyApp.Appsignal.custom_on_create_fun/1
```
