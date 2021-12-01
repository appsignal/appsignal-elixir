---
bump: "patch"
type: "fix"
---

Fix the download of the agent during installation when Erlang is
using an OpenSSL version that does not support TLS 1.3, such as versions below OpenSSL 1.1.1.
