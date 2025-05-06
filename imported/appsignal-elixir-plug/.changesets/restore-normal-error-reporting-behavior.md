---
bump: patch
type: fix
---

Restore normal error reporting behavior by removing the default included `Plug.ErrorHandler` in the `Appsignal.Plug` module. It will now longer render a page with HTTP status 500 and the response body "Something went wrong".
