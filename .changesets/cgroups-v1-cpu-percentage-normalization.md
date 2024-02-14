---
type: "change"
bump: "minor"
---

**Breaking change**: Normalize CPU metrics for cgroups v1 systems. When we can detect how many CPUs are configured in the container's limits, we will normalize the CPU percentages to a maximum of 100%. This is a breaking change. Triggers for CPU percentages that are configured for a CPU percentage higher than 100% will no longer trigger after this update. Please configure triggers to a percentage with a maximum of 100% CPU percentage.
