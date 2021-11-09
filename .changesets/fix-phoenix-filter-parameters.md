---
bump: "patch"
---

Fix a bug where setting the `:phoenix, :filter_parameters` configuration key to an allow-list of the form `{:keep, [keys]}` would apply this filtering to all sample data maps.
