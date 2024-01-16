---
bump: "patch"
type: "change"
---

Add support for lists in the sample data as root values on spans, as shown below. Previously we only supported lists as nested objects in maps.

```elixir
Appsignal.Span.set_sample_data(
  Appsignal.Tracer.root_span,
  "custom_data",
  [
    "value 1",
    "value 2"
  ]
)
```
