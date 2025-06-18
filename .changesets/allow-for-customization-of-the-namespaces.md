---
bump: patch
type: change
---

Allow for more customization of trace namespaces during the trace's lifetime.
Previously, it was not possible to customize the namespace of Absinthe traces before the Absinthe instrumentation had run.
This is now possible, as the Absinthe instrumentation will only set the namespace if it has not been set already.
