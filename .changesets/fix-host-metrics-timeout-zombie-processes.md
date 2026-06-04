---
bump: patch
type: fix
integrations: all
---

Fix host-metrics leaking zombie `[timeout]` processes in Alpine linux containers.

Before this release AppSignal agent relied on a proper init process that reaps child processes killed by system `timeout`. Now the agent terminates and reaps unresponsive child processes in host-metrics collection and a subreaper is no longer required.
