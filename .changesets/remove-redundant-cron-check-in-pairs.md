---
bump: patch
type: change
---

Remove redundant cron check-in pairs. When more than one pair of start and finish cron check-in events is reported for the same identifier in the same period, only one of them will be reported to AppSignal.
