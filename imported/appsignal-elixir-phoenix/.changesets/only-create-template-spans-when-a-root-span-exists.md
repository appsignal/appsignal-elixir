---
bump: "patch"
---

Don't track Phoenix render template events without root spans. For live view a lot of template events were tracked as separate incidents, causing a lot noise on the incidents overview for an app. This patch makes sure `Appsignal.View` doesn't create root spans anymore, skipping any template renders that can't be added to any existing trace.
