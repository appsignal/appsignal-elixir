---
bump: "patch"
integrations: "all"
type: "add"
---

Implement the `ignore_logs` configuration option, which can also be configured as the `APPSIGNAL_IGNORE_LOGS` environment variable.

The value of `ignore_logs` is a list (comma-separated, when using the environment variable) of log line messages that should be ignored. For example, the value `"start"` will cause any message containing the word "start" to be ignored. Any log line message containing a value in `ignore_logs` will not be reported to AppSignal.

The values can use a small subset of regular expression syntax (specifically, `^`, `$` and `.*`) to narrow or expand the scope of lines that should be matched.

For example, the value `"^start$"` can be used to ignore any message that is _exactly_ the word "start", but not messages that merely contain it, like "Process failed to start". The value `"Task .* succeeded"` can be used to ignore messages about task success regardless of the specific task name.

