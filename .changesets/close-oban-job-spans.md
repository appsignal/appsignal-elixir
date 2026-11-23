---
bump: patch
type: fix
---

Close the span of an Oban job when the job leaves open a span it opened. The job's state and result were set on the left-open span, which was closed in its place, and the job's span was never reported.
