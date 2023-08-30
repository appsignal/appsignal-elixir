---
bump: "patch"
type: "change"
---

Bump agent to 6133900.

- Fix `disk_inodes_usage` metric name format to not be interpreted as a JSON object.
- Convert all OpenTelemetry sum metrics to AppSignal non-monotonic counters.
- Rename standalone agent's `role` option to `host_role` so it's consistent with the integrations naming.
