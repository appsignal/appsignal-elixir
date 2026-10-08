---
bump: major
type: change
---

End the spans left open inside a block instrumented with `Appsignal.instrument/2,3` or a decorated function, a request instrumented with `Appsignal.Plug` or Phoenix, or a LiveView event, when that block, request or event ends. They no longer stay open and become the parent of later work in the same process. Ones with neither a name nor a category are named `[unfinished span]`. A span opened inside an instrumented block and closed only after the block returns is now ended when the block returns.
