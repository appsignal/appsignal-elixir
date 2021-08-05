---
bump: "patch"
---

Fix Apple ARM detection. It wasn't properly detected as an Apple ARM host because the installer did not account for an architecture String a without 32/64-bit indicator.
