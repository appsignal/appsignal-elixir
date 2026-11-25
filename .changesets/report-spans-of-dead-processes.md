---
bump: minor
type: change
---

Report the spans a process leaves open when it exits, crashes or is killed. The end time for those spans is set to the time at which the process went down, and their traces are reported, potentially truncated. Before this change, these unfinished traces would not be reported.
