---
bump: major
type: change
---

Require `telemetry` 0.4.3 or newer. Earlier versions do not tell the start and stop events of a span apart, which the LiveView integration now relies on to close the span it opened.
