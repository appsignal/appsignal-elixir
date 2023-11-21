---
bump: "patch"
type: "change"
---

Bump agent to eec7f7b

Updated the probes dependency to 0.5.2. CPU usage is now normalized to the number of CPUs available to the container. This means that a container with 2 CPUs will have its CPU usage reported as 50% when using 1 CPU instead of 100%. This is a breaking change for anyone using the cpu probe.

If you have CPU triggers set up based on the old behaviour, you might need to update those to these new normalized values to get the same behaviour. Note that this is needed only if the AppSignal integration package you're using includes this change.
