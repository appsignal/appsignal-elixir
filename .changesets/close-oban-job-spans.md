---
bump: patch
type: fix
---

Close the span of an Oban job, and any span left open inside it, when the job ends. When the job left a span open, the job's state and result were set on that span, which was closed in its place, and the job's span was never reported.
