---
bump: "patch"
type: "change"
---

Bump agent to 06391fb

- Accept "warning" value for the `log_level` config option.
- Add aarch64 Linux musl build.
- Improve debug logging from the extension.
- Fix high CPU issue for appsignal-agent when nothing could be read from the socket.
