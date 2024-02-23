---
bump: "patch"
type: "fix"
---

Fix (sub)traces not being reported in their entirety when the OpenTelemetry exporter sends one trace in multiple export requests. This would be an issue for long running traces, that are exported in several requests.

