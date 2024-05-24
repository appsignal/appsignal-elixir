---
bump: minor
type: change
---

Group GraphQL queries by operation names if available. It will no longer group all errors and performance measurements under the same action name. If no operation name is set, it will use the default action name of the HTTP request route, like `POST /graphql`.

If you do not wish to use the operation name, or customize the action name for the GraphQL query request, use the `Appsignal.Span.set_name` in a plug middleware that is called before or after the HTTP request is made:

```elixir
Appsignal.Span.set_name(Appsignal.Tracer.root_span(), "MyActionName")
```
