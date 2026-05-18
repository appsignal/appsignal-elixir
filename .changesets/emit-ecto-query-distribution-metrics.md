---
bump: patch
type: add
---

Emit distribution metrics from the Ecto integration.

Each Ecto query telemetry event now also reports its timing values as `ecto_query_time`, `ecto_queue_time`, `ecto_decode_time`, `ecto_idle_time` and `ecto_total_time` distribution metrics.

All five metrics are tagged by `repo` and `hostname`. The `ecto_query_time`, `ecto_decode_time` and `ecto_total_time` metrics are additionally tagged by `repo` and `source` (the Ecto table).

This surfaces pool waits, decode time, idle connection time and per-table latency as standalone metrics in addition to the existing query span.
