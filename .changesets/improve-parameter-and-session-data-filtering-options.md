---
bump: "patch"
---

Improve parameter and session data filtering options. Previously all filtering was done with one combined denylist of parameters and session data. Now `filter_parameters` only applies to parameters, and `filter_session_data` only applies to session data.
