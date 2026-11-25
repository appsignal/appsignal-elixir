---
bump: patch
type: change
---

When a span created by a decorated function, or around the function passed to `Appsignal.instrument/2,3`, is closed when the function ends, close all of the span's children as well.
