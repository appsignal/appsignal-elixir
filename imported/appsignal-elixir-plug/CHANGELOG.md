# 2.0.5
* Allow :appsignal versions between 2.0.6 and 3.0.0

# 2.0.4
Drop all errors with a plug_status < 500, not just WrapperErrors. PR #7

# 2.0.3
Match on :done instead of true for plug_session_fetch. Commit 8af8836f17db60484fc6d02143666345fe607435

# 2.0.2
Add status and request_id and restore headers in Appsignal.Metadata. PR #5

# 2.0.1
Explicitly ignore return from span functions in Appsignal.Plug. PR #4

# 2.0.0
* Initial release, extracted from appsignal-elixir 🎉
