---
bump: "minor"
---

Adds metrics for the Erlang scheduler utilization to the minutely probes.

The metric name is `erlang_scheduler_utilization`. It is reported as a
percentage value.

The total utilization across all schedulers is reported within this metric
with the tag `type` set to `total`. 

The utilization of each of the schedulers is reported with the tag `type`
set to `scheduler` and the tag `id` set to the scheduler's ID.
