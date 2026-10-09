---
bump: patch
type: change
---

Stop starting a trace for a Phoenix template rendered while no span is open, such as an error page rendered after the request's spans were closed, or a template rendered outside a request. These were reported as separate traces named after the template.
