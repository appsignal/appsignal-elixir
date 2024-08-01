---
bump: patch
type: change
integrations:
- elixir
- nodejs
- python
- ruby
---

Improve sanitization of INSERT INTO ... VALUES with multiple groups by removing additional repeated groups.

This makes the query easier to read, and mitigates an issue where processing many events with slightly distinct queries would cause some event details to de discarded.
