---
bump: minor
type: remove
integrations: all
---

Remove the OpenTelemetry beta feature in favor of the new [AppSignal collector](https://docs.appsignal.com/collector). If you are using the AppSignal agent to send OpenTelemetry data in our public beta through the `/enriched` endpoint on the agent's HTTP server, please migrate to the collector to continue using the beta. The collector has a much better implementation of this feature for the beta.
