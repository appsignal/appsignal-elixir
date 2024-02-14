---
type: "change"
bump: "patch"
---

Support fractional CPUs for cgroups v2 metrics. Previously a CPU count of 0.5 would be interpreted as 1 CPU. Now it will be correctly seen as half a CPU and calculate CPU percentages accordingly.

