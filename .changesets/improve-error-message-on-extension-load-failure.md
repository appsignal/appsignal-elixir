---
bump: "patch"
type: "fix"
---

Improve the error message on extension load failure. The error message will now print more details about the installed and expected architecture when they mismatch. This is most common on apps mounted on a container after first being installed on the host with a different architecture than the container.
