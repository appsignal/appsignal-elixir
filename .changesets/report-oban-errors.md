---
bump: "patch"
type: "add"
---

Add a `report_oban_errors` config option to decide when to report Oban errors. When set to `"all"`, all errors will be reported; when set to `"none"`, no errors will be reported. Set it to `"discard"` to only report errors when the job is discarded due to the error and won't be re-attempted.
