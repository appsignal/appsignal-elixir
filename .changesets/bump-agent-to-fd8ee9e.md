---
bump: "patch"
type: "change"
---

Bump agent to fd8ee9e.

- Rely on APPSIGNAL_RUNNING_IN_CONTAINER config option value before other environment factors to determine if the app is running in a container.
- Fix container detection for hosts running Docker itself.
- Add APPSIGNAL_STATSD_PORT config option.
