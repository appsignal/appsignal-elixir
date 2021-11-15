---
bump: "patch"
---


Remove the `valid` key from the diagnose output. It's not a configuration option that
can be configured, but an internal state check if the configuration was considered valid.
