---
bump: "patch"
type: "add"
---

Implement CPU count configuration option. Use it to override the auto-detected, cgroups-provided number of CPUs that is used to calculate CPU usage percentages.

To set it, use the `cpu_count` configuration option, or the `APPSIGNAL_CPU_COUNT` environment variable.
