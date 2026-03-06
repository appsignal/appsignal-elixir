---
bump: minor
type: add
---

Add HTTPoison instrumentation. HTTP requests made with HTTPoison will appear as `request.httpoison` events on your performance samples' event timeline.

HTTPoison does not emit telemetry events, so the instrumentation is opt-in. Use `Appsignal.HTTPoison` in place of `HTTPoison` when making requests, or replace `use HTTPoison.Base` with `use Appsignal.HTTPoison.Base` for custom client modules. Response types (`%HTTPoison.Response{}`, `%HTTPoison.Error{}`, etc.) are unchanged.
