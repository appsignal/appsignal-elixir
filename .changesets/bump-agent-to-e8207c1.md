---
bump: "patch"
type: "change"
---

Bump agent to e8207c1.

- Add `memory_in_percentages` and `swap_in_percentages` host metrics that represents metrics in percentages.
- Ignore `/snap/` disk mountpoints.
- Fix issue with the open span count in logs being logged as a negative number.
- Fix agent's TCP server getting stuck when two requests are made within the same fraction of a second.
