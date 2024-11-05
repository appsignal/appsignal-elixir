---
bump: patch
type: add
integrations:
- ruby
- elixir
- nodejs
- python
---

Set the app revision config option for Scalingo deploys automatically. If the `CONTAINER_VERSION` system environment variable is present, it will use used to set the `revision` config option automatically. Overwrite it's value by configuring the `revision` config option for your application.
