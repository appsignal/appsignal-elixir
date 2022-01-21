---
bump: "patch"
type: "deprecate"
---

Deprecate `skip_session_data` option in favor of the newly introduced `send_session_data` option.
If it is configured, it will print a warning on AppSignal load, but will also retain its
functionality until the config option is fully removed in the next major release.
