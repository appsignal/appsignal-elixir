---
bump: "patch"
---

Add new config option to enable/disable StatsD server in the AppSignal agent. This new config option is called `enable_statsd` and is set to `false` by default. If set to `true`, the AppSignal agent will start a StatsD server on port 8125 on the host.
