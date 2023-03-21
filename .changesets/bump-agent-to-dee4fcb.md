---
bump: "patch"
type: "change"
---

Bump agent to dee4fcb.

- Support cgroups v2. Used by newer Docker engines to report host metrics. Upgrade if you receive no host metrics for Docker containers.
- Remove trailing comments in SQL queries, ensuring queries are grouped consistently.
