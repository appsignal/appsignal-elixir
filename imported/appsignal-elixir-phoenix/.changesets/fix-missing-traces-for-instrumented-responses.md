---
bump: patch
type: fix
---

Fix traces going missing when a Phoenix response is sent from inside an instrumented block. This happens when `Appsignal.instrument/2`, or a function decorated with `transaction_event()`, wraps a call that sends the response, such as `render/2` or `redirect/2`.

On web servers that serve more than one request per process, such as Bandit, this also affected the requests that followed on the same connection. Those requests were not reported at all, and an error reported by one of them could show the action, parameters, environment and session data of an earlier request. On Cowboy, where each request gets its own process, only the request that sent its response inside an instrumented block was affected.
