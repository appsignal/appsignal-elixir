---
bump: "patch"
type: "add"
---

Log messages are now sent through a centralised logger, defaulting to logging
to the `/tmp/appsignal.log` file.
To log to standard output instead, set the `log` config property to `"stdout"`.
