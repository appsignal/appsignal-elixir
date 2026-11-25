---
bump: patch
type: fix
---

Fixed an issue where, when a Phoenix request's action raised, its router dispatch span would be left open, and the resulting error trace would not contain the router dispatch span.
