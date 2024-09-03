---
bump: patch
type: change
---

Send check-ins concurrently. When calling `Appsignal.CheckIn.cron`, instead of blocking the current process while the check-in events are sent, schedule them to be sent in a separate process.
