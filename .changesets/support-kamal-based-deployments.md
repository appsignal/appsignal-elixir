---
bump: "patch"
integrations: "all"
type: "add"
---

Support Kamal-based deployments. Read the `KAMAL_VERSION` environment variable, which Kamal exposes within the deployed container, if present, and use it as the application revision if it is not set. This will automatically report deploy markers for applications using Kamal.

