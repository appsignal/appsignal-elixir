# Error Handling and Error Backend

The AppSignal Elixir integration provides multiple mechanisms for capturing and reporting errors.
This document explains the error handling architecture, the error backend, and why that's disabled by default.

## Error Reporting Overview

There are three ways errors get reported to AppSignal:

1. **Manual error reporting** - `Appsignal.set_error/2` and `Appsignal.send_error/2`
2. **Automatic instrumentation** - Framework integrations (Phoenix, Oban) catch errors
3. **Error backend** - Logger backend that catches unhandled crashes (disabled by default)

## Manual Error Reporting

See instrumentation-decorators.md for details on `set_error` and `send_error`.

Quick summary:
- `set_error/2` - Adds error to existing span (within a web request or job)
- `send_error/2` - Creates new span for error (outside any trace)

## Error Backend

The error backend is a Logger backend that intercepts error reports from Erlang's error logger.

### Architecture

The error backend implements the `:gen_event` behavior.
It attaches to Erlang's internal `:error_logger` as a backend.

### What It Catches

The error backend processes error events from the Logger.

**Event Structure:**

- **Level**: `:error` (only error-level events are processed)
- **Group leader**: Must be on the current node (prevents duplicate reporting in distributed systems)
- **Metadata**: Contains crash information including `crash_reason`, `pid`, `conn`, etc.

### Crash Reason Handling

The backend looks for a `crash_reason` in the metadata.
The crash reason is a tuple: `{reason, stacktrace}`

### PID Extraction

The PID is extracted from different report structures.

**Why Different Sources?**

- Phoenix/Plug crashes include a `conn` struct with the request process's PID in `conn.owner`
- Generic crashes include a `pid` field directly
- Some crashes don't include any process information

### Filtering Cowboy Errors

Cowboy errors are explicitly filtered out.

**Why?**

Cowboy errors were causing issues:

1. They don't have useful context for debugging
2. They can have non-list stacktraces that crashed the handler
3. Phoenix's built-in error handling already reports these errors properly

Before this fix, only cowboy errors without a `conn` were filtered.
The fix ensures ALL cowboy errors are ignored, even those with conns.

## Why It's Disabled by Default

The error backend was changed to be **disabled by default** in June 2024.

### Historical Context

The error backend was created before AppSignal had proper framework integrations.
It was the primary way to catch unhandled errors in Elixir applications.

### Problems with the Error Backend

**1. Lack of Context**

Errors caught by the backend have minimal context:
- No request parameters
- No session data
- No custom attributes
- Just the raw exception and stacktrace

This makes debugging difficult.

**2. Duplicate Reporting**

Modern framework integrations (Phoenix, Oban) already report errors properly with full context.
Although we have error ignoring, sometimes the error backend would catch the same errors again, leading to duplicates.

**3. Confusing Results**

Because the errors lack context, they appear in AppSignal without the information needed to understand or fix them.
