---
bump: patch
type: add
---

Set render metadata as tags on render error. When a template rendering error is reported, its backtrace is limited to the Elixir process that is spawned to render the template. Add information about the template and view being rendered as tags, to provide additional context about the error.
