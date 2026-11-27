---
bump: patch
type: fix
---

Keep instrumenting Phoenix, LiveView, Finch, Tesla, Oban, Broadway and Absinthe after an error in AppSignal's handling of one of their events. The error is logged, and the integration keeps handling later events, where before it stopped instrumenting that event until the application restarted.
