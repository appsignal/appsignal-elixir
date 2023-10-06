---
bump: "patch"
type: "fix"
---

Fix configuration options set with atoms. The options `log` and `log_level` can now be set as an Atom, and we'll cast them to a string internally to avoid any `ArgumentError` from the Nif.
