---
bump: "patch"
---

Add the Erlang scheduler utilization to the metrics reported by the minutely probes. The metric is
reported as a percentage value with the name `erlang_scheduler_utilization`, with the tag `type` set to `"scheduler"` and the tag `id` set to the ID of the scheduler in the Erlang VM.
