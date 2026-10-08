---
bump: patch
type: fix
---

Fixed an issue where a Phoenix request whose action raised left its router dispatch span open, so the error's trace was reported without it. Fixed an issue where a Phoenix request that failed in a plug in the endpoint or in a router pipeline, such as one rejected by `Plug.CSRFProtection` or one whose body failed to parse, was never reported or was reported with spans left open. Fixed an issue where a span left open during a request on a Bandit connection became the parent of the next request on that connection.
