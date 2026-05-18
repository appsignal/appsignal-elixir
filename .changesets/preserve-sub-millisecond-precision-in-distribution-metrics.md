---
bump: patch
type: fix
---

Preserve sub-millisecond precision when reporting timing distribution metrics.

The Ecto (`ecto_query_time`, `ecto_queue_time`, `ecto_decode_time`, `ecto_idle_time`, `ecto_total_time`) and Oban (`oban_job_duration`, `oban_job_queue_time`) distribution metrics now report fractional milliseconds, instead of being truncated to whole milliseconds. Sub-millisecond measurements were previously rounded down to zero.
