---
bump: "patch"
type: "fix"
---

Fix a bug where setting the `:phoenix, :filter_parameters` configuration key to an allow-list of the form `{:keep, [keys]}` would apply this filtering to all sample data maps. The filtering is now only applied to the params sample data map.
