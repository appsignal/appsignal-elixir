---
bump: patch
type: fix
---

Fixed an issue where a request that called `Appsignal.Tracer.ignore/0` on a Bandit connection stopped AppSignal from recording the later requests on that connection, and where the ignored request was still reported.
