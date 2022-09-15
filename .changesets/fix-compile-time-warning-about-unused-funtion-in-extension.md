---
bump: "patch"
type: "fix"
---

Fix compile-time warning about an unused funtion in the extension. The `_set_span_attribute_sql_string` function wasn't hooked up, which didn't produce any issues since the SQL queries coming from Ecto don't need to be sanitized any further (sensitive data is already stripped out). This patch still runs them through AppSignal's SQL sanitizer to fix the warning and behave as promised, theoretically.
