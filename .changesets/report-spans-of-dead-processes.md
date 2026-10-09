---
bump: minor
type: change
---

Report the spans a process leaves open when it exits, crashes or is killed. They are ended at the time the process went down, so their traces are reported, truncated, instead of not at all. Child spans without a name are named `[unfinished transaction event]`. Spans registered for another process with the `:pid` option of `Appsignal.Tracer.create_span/3` are now removed when that process exits.
