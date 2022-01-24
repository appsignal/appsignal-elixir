---
bump: "patch"
type: "fix"
---

Prefer the value of the `log_level` config option, instead of the deprecated `debug` config option, when deciding whether to log a debug message. If `log_level` does not have a value, or its value is invalid, the values of the deprecated `debug` and `transaction_debug_mode` config options are taken into account.
