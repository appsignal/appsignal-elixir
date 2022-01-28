---
bump: "patch"
type: "change"
---

Update the plug integration to listen to the `send_session_data` config option instead of
`skip_session_data`. The `send_session_data` config option is backwards compatible with
the `skip_session_data` config option.
