---
bump: patch
type: change
---

Update the `result` attribute reported for Oban jobs. Instead of it including the job's whole return value, it only contains the Oban job control value: `:ok`/`:error`/`:discard`/`:cancel`/`:snooze`.
The reason for a discard, cancel, error or snooze result will be stored in the new `result_reason` attribute.
Any `:ok` result reasons and unexpected result values are ignored. This is to avoid storing sensitive data in the attributes and to make it easier to filter by job control value in the interface.
