---
bump: patch
type: fix
---

End a Phoenix request's root span when its action finishes, rather than when the response is sent. A request with a chunked response no longer ends before its action streams the response.
