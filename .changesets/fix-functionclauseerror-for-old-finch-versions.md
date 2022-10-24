---
bump: "patch"
type: "fix"
---

Fix FunctionClauseError for old Finch versions. This change explicitly ignores events from old Finch versions, meaning only Finch versions 0.12 and above will be instrumented, but using Finch versions 0.11 and below won't cause an event handler crash.
