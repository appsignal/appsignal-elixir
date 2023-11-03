---
bump: "patch"
type: "change"
---

Bump agent to 1dd2a18.

- When adding an SQL body attribute via the extension, instead of truncating the body first and sanitising it later, sanitise it first and truncate it later. This prevents an issue where queries containing very big values result in truncated sanitisations.
