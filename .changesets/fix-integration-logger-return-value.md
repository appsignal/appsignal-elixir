---
bump: patch
type: fix
---

Return `:ok` from `Appsignal.IntegrationLogger` functions when the message is below the configured log level, as specified, instead of `nil`.
