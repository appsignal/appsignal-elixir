---
bump: minor
type: add
---

Report LiveComponent traces and events separately from LiveView traces and events.

Traces in AppSignal representing updates and event handlers in components will no longer be represented as calls to the view in which the component is mounted, and their events will be part of the `live_component` group.

This makes it possible to obtain performance measurements for each component individually, instead of grouped by the view that mounts the component.