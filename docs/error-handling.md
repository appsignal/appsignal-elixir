# Error Handling and Error Backend

The AppSignal Elixir integration provides multiple mechanisms for capturing and reporting errors.
This document explains the error handling architecture, the error backend, and why it's disabled by default.

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

The error backend implements the `:gen_event` behavior (lib/appsignal/error/backend.ex:9):

```elixir
@behaviour :gen_event
```

It attaches to Elixir's Logger as a backend:

```elixir
def attach do
  case Logger.add_backend(Appsignal.Error.Backend) do
    {:error, error} ->
      Logger.warning("Appsignal.Error.Backend not attached to Logger: #{error}")
      :error

    _ ->
      Appsignal.IntegrationLogger.debug("Appsignal.Error.Backend attached to Logger")
      :ok
  end
end
```

### What It Catches

The error backend processes error events from the Logger (lib/appsignal/error/backend.ex:25-35):

```elixir
def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
  metadata
  |> Enum.into(%{})
  |> handle_report()

  {:ok, state}
end

def handle_event(_event, state) do
  {:ok, state}
end
```

**Event Structure:**

- **Level**: `:error` (only error-level events are processed)
- **Group leader**: Must be on the current node (prevents duplicate reporting in distributed systems)
- **Metadata**: Contains crash information including `crash_reason`, `pid`, `conn`, etc.

### Crash Reason Handling

The backend looks for a `crash_reason` in the metadata (lib/appsignal/error/backend.ex:37-49):

```elixir
defp handle_report(%{crash_reason: {reason, stacktrace}} = report) do
  pid = report_pid(report)

  unless :cowboy in report_domains(report) do
    pid
    |> @tracer.lookup()
    |> do_handle_report(pid, reason, stacktrace)
  end
end

defp handle_report(_) do
  :ok
end
```

The crash reason is a tuple: `{reason, stacktrace}`

### PID Extraction

The PID is extracted from different report structures (lib/appsignal/error/backend.ex:51-56):

```elixir
defp report_pid(%{conn: %{owner: pid}}), do: pid  # Phoenix/Plug crash with conn
defp report_pid(%{pid: pid}), do: pid              # Generic crash with PID
defp report_pid(_), do: nil                        # No PID available
```

**Why Different Sources?**

- Phoenix/Plug crashes include a `conn` struct with the request process's PID in `conn.owner`
- Generic crashes include a `pid` field directly
- Some crashes don't include any process information

### Filtering Cowboy Errors (dcdac33e, 2023-06-12)

Cowboy errors are explicitly filtered out:

```elixir
unless :cowboy in report_domains(report) do
  # ... process error
end
```

**Why?**

Cowboy errors were causing issues:

1. They don't have useful context for debugging
2. They can have non-list stacktraces that crashed the handler
3. Phoenix's built-in error handling already reports these errors properly

Before this fix, only cowboy errors without a `conn` were filtered.
The fix ensures ALL cowboy errors are ignored, even those with conns.

**See:** https://github.com/appsignal/appsignal-elixir/issues/850

### Span Lookup and Creation

The backend looks up existing spans for the process (lib/appsignal/error/backend.ex:58-72):

```elixir
defp do_handle_report([{_pid, :ignore}], _, _, _) do
  :ok
end

defp do_handle_report([], pid, reason, stacktrace) do
  "background_job"
  |> @tracer.create_span(nil, pid: pid)
  |> set_error_data(reason, stacktrace)
end

defp do_handle_report(spans, _, reason, stacktrace) when is_list(spans) do
  {_pid, span} = List.last(spans)

  set_error_data(span, reason, stacktrace)
end
```

**Three Scenarios:**

1. **Process is ignored** - Do nothing
2. **No existing spans** - Create new "background_job" span for the error
3. **Existing spans** - Add error to the last (current) span

### Setting Error Data

Error data is added to the span with a special tag (lib/appsignal/error/backend.ex:90-95):

```elixir
defp set_error_data(span, reason, stacktrace) do
  span
  |> @span.add_error(:error, reason, stacktrace)
  |> @span.set_sample_data("tags", %{"reported_by" => "error_backend"})
  |> @tracer.close_span()
end
```

The `"reported_by" => "error_backend"` tag indicates the error was caught by the backend, not through manual instrumentation.

## Why It's Disabled by Default (cb7c2e9d, 2024-06-04)

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
The error backend would catch the same errors again, leading to duplicates.

**3. Confusing Results**

Because the errors lack context, they appear in AppSignal without the information needed to understand or fix them.

### When to Enable It

Enable the error backend if:
- You're using custom GenServers/processes without proper instrumentation
- You have background work that isn't covered by framework integrations
- You're missing errors that should be reported

```elixir
# config/config.exs
config :appsignal, :config,
  enable_error_backend: true
```

### Configuration

Check if enabled (lib/appsignal/config.ex:188-193):

```elixir
def error_backend_enabled? do
  case Application.fetch_env(:appsignal, :config) do
    {:ok, value} -> !!Access.get(value, :enable_error_backend, false)
    _ -> false
  end
end
```

Attachment happens during application start if enabled (lib/appsignal.ex:28-30):

```elixir
if Config.error_backend_enabled?() do
  Appsignal.Error.Backend.attach()
end
```

## Integration with Framework Error Handlers

The error backend **does not replace** framework-specific error handling.
It's a fallback for errors that aren't caught by other means.

### Phoenix

Phoenix's error view and exception tracking work independently of the error backend.
The Plug instrumentation catches errors during request processing.

### Oban

Oban's exception handler reports errors with full job context.
The error backend would only catch errors outside of job execution.

### GenServers

Custom GenServers that crash without supervision will be caught by the error backend (if enabled).

## Stacktrace Handling

The stacktrace formatter handles edge cases (lib/appsignal/stacktrace.ex):

```elixir
def format(stacktrace) when is_list(stacktrace) do
  Enum.map(stacktrace, &format_stacktrace_entry/1)
end

def format(_stacktrace) do
  []
end
```

**Why Guard for Lists?**

In some situations (like cowboy errors), the stacktrace isn't actually a list.
It might be a tuple or other structure.

Returning an empty list prevents the error handler from crashing.

## Process Isolation

The error backend only processes errors from the current node:

```elixir
def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
  # ... process error
end
```

**Why Check the Group Leader's Node?**

In distributed Erlang systems, error reports can propagate across nodes.
Without this check, the same error could be reported multiple times (once per node).

The group leader check ensures each error is only processed on the node where it originated.

## Testing Without the Error Backend

In tests, the error backend is typically not attached (unless specifically testing it).

Tests use compile-time configuration to inject fake implementations:

```elixir
# config/test.exs
config :appsignal, appsignal_tracer, Appsignal.Test.Tracer
config :appsignal, appsignal_span, Appsignal.Test.Span
```

The error backend respects these test implementations (lib/appsignal/error/backend.ex:6-7):

```elixir
@tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
@span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
```

## Key Design Decisions Summary

| Decision | Rationale |
|----------|-----------|
| Disabled by default | Modern integrations provide better context; reduces confusion |
| Filter cowboy errors | Phoenix handles these better; prevents duplicate/bad reports |
| Check group leader node | Prevent duplicate reports in distributed systems |
| Handle non-list stacktraces | Edge case compatibility; prevents backend crashes |
| Tag with "reported_by" | Distinguish backend-caught errors from manually reported ones |
| Create "background_job" spans | Provide namespace for errors without existing spans |
| Use last span in list | Attach error to current span, not parent spans |

## Migration Guide

If you're upgrading and rely on the error backend:

1. **Audit your error reports** - Check what errors the backend is catching
2. **Add explicit instrumentation** - Use `Appsignal.send_error/2` for important processes
3. **Enable if necessary** - Set `enable_error_backend: true` if you can't instrument everything

If you're seeing errors you expect to be reported but aren't:

1. **Check framework integration** - Ensure Ecto/Phoenix/Oban integrations are enabled
2. **Add manual reporting** - Use `set_error` or `send_error` in rescue blocks
3. **Enable error backend temporarily** - See what it catches, then instrument those areas

## Future Direction

The error backend is expected to be removed in a future major version.
The package is moving toward explicit instrumentation through:

- Framework integrations (Phoenix, Oban, Ecto)
- Telemetry attachments
- Manual error reporting (`set_error`, `send_error`)

These provide better context and more control than the catch-all error backend approach.
