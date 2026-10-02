---
bump: patch
type: change
---

Keep reporting a request's name, parameters, session data and template tags on the request's own sample when its response is rendered or sent inside a root span opened during the request, such as a function decorated with `transaction()`. Without this, AppSignal for Elixir versions in which `Appsignal.Tracer.root_span/0` returns the root span of the current trace do not report those requests.
