---
bump: patch
type: security
---

[CVE-2026-32686](https://cna.erlef.org/cves/CVE-2026-32686.html) describes an unauthenticated remote Denial of Service vulnerability in `decmimal` before `3.0.0`.  Loosen `decimal` requirement to allow `~> 3.0` and fix compatibility with `ecto`.
