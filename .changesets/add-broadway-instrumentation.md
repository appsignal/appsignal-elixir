---
bump: minor
type: add
---

Automatically instrument Broadway library.

[Broadway](https://elixir-broadway.org/) is an Elixir library for building
concurrent and multi-stage data ingestion and data processing pipelines.

When Broadway processes one or more messages, a trace is created to represent
the processing of these messages.  Independent root spans encompass the call to
`prepare_messages/2` and `handle_message/3`.

This instrumentation is enable by default and only available for Broadway
versions higher than 1.0.0.
