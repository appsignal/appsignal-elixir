---
bump: minor
type: add
---

Automatically instrument Broadway applications.

When your Broadway application's processor processes one or more messages, a trace will be created to
represent the processing of these messages.  The root span encompasses the call to the `prepare_messages/2`
callback, if defined, and each of its child spans will represent the individual processing of each of these
messages through the `handle_message/3` callback.
