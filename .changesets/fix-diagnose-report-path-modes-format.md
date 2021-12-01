---
bump: "patch"
type: "fix"
---

Transmit the path file modes in the diagnose report as an octal number. Previously it send values like `33188` and now it transmits `100644`, which is a bit more human readable.
