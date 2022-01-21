---
bump: "patch"
type: "add"
---

Add `send_session_data` option to configure if session data is automatically included in
spans. By default this is turned on. It can be disabled by configuring
`send_session_data` to `false`.
