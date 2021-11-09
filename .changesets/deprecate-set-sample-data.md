---
bump: "patch"
---

Deprecate the `Appsignal.Span.set_sample_data/3` method, which will be removed in the next major release. Use the `set_environment/1`, `set_session_data/1`, `set_params/1`, `set_tags/1` or `set_custom_data/1` methods on `Appsignal.Tracer` instead.
