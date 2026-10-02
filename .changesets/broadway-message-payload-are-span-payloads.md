---
bump: patch
type: fix
---

Broadway message payloads are span payloads too

The handling of Broadway message payload was being incorrectly
transposed into a span.  It was being set as `message` (the property
name within Broadway's telemetry event) when in its correct definition
in AppSignal's span structure is `payload`.
