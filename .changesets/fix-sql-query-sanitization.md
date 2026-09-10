---
bump: patch
type: fix
integrations: all
---

Fix the sanitization of function arguments in SQL statements.

Before this release, SQL sanitization of function arguments stripped out parts of the SQL statement after the function argument list.
