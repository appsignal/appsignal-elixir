---
bump: patch
type: fix
---

Fix compatibility with Finch 0.22+. This change moves SSL and proxy options to pool-level `conn_opts` in `Finch.start_link`.
