---
bump: patch
type: fix
---

Report the error of a Phoenix request that fails in a plug, in the endpoint or in a router pipeline, along with the request's parameters, environment and response status. These requests were reported without their error, and without their request data when the plug was in the endpoint. As for other requests, errors with a status below 500, such as a request body that fails to parse, are not reported.
