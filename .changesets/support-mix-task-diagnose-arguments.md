---
bump: "patch"
---

Support mix task diagnose arguments. When an app is released with `mix release` CLI arguments cannot normally be passed to the diagnose task. Use the `eval` command pass along the CLI arguments as function arguments.

```
mix format
# Without arguments
bin/your_app eval ':appsignal_tasks.diagnose()'
# With arguments
bin/your_app eval ':appsignal_tasks.diagnose(["--send-report"])'
```
