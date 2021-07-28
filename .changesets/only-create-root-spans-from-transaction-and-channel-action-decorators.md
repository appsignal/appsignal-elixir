---
bump: "patch"
---

Only create root spans from transaction and channel action decorators, as they're meant to only be used when no span exists yet.
