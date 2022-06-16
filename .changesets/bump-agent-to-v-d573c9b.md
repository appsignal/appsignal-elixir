---
bump: "patch"
type: "change"
---

Bump agent to v-d573c9b

- Clean up payload storage before sending. Should fix issues with locally queued payloads blocking data from being sent.
- Add OpenTelemetry support for the Span API. Not currently implemented in this package's extension.
