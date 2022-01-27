---
bump: "patch"
type: "change"
---

Add the config "override" source to better communicate and help debug when certain config options are set. This is used by the diagnose report. The override source is used to set the new config option value when a config option has been renamed, like `send_session_data`.
