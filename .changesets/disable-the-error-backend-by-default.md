---
bump: minor
type: change
---

Disable the error backend by default

With new ways of instrumenting errors added, the error backend is unneeded in most setups.
Disable it by default to make it opt-in.
