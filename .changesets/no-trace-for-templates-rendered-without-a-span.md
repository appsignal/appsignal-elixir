---
bump: patch
type: change
---

Prevent starting a trace for the rendering of a Phoenix template in a non-instrumented context, such as when a template is rendered outside of a Phoenix request. Before this change, these would be reported as separate traces named after the template.
