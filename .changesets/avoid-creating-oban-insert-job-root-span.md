---
bump: "patch"
type: "fix"
---

Avoid reporting an Oban insert job event as a new incident. This should fix an issue where "insert job" events with little information show up in AppSignal as their own incidents when Oban jobs are inserted from an uninstrumented context that has no parent spans.
