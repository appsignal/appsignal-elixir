---
bump: minor
type: add
---

Add the `instrument_phoenix` option, to turn off the automatic instrumentation of Phoenix requests and template rendering. It's `true` by default. Set it with `config :appsignal, :config, instrument_phoenix: false` or the `APPSIGNAL_INSTRUMENT_PHOENIX` environment variable.
