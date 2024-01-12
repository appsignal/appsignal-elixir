---
bump: "patch"
type: "fix"
---

Add support for keywords lists in sample data on spans. These would previously be shown an empty list.

```elixir
Appsignal.Span.set_sample_data(
  Appsignal.Tracer.root_span,
  "custom_data",
  %{"keyword_list": [foo: "some value", "bar": "other value"]}
)
```
