---
bump: patch
type: fix
---

Fixed an issue where, when a Phoenix request failed due to an endpoint plug or due to a failure in the router pipeline, such as when `Plug.CSRFProtection` rejects a request or when the body fails to parse, the trace for that request wouldn't be reported, or would be missing spans when reported.
