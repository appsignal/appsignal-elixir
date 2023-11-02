---
bump: "patch"
type: "change"
---

Bump agent to b604345.

- Add an exponential backoff to the retry sleep time to bind to the StatsD, NGINX and OpenTelemetry exporter ports. This gives the agent a longer time to connect to the ports if they become available within a 4 minute window.
- Changes to the agent logger:
  - Logs from the agent and extension now use a more consistent format in logs for spans and transactions.
  - Logs that are for more internal use are moved to the trace log level and logs that are useful for debugging most support issues are moved to the debug log level. It should not be necessary to use log level 'trace' as often anymore. The 'debug' log level should be enough.
- Add `running_in_container` to agent diagnose report, to be used primarily by the Python package as a way to detect if an app's host is a container or not.
