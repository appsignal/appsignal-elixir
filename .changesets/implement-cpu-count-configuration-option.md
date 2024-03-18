---
bump: "patch"
type: "add"
---

Implement CPU count configuration option. Use it to override the auto-detected, cgroups-provided number of CPUs that is used to calculate CPU usage percentages.

To set it, use the `APPSIGNAL_CPU_COUNT` environment variable, the `cpu_count`
configuration option in the Ruby, Elixir or Python integrations, the `cpuCount` attribute in the Node.js instrumentation, or the `cpu_count` configuration option in the stand-alone agent TOML configuration file.

