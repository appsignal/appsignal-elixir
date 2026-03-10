# Tracer Registry (ETS Table)

The Appsignal Elixir integration uses an ETS table as a registry to track spans across processes.
This document explains the design decisions and implementation details.

## Overview

The tracer registry is implemented as an ETS table named `$appsignal_registry` that maintains a mapping of process PIDs to their active spans.
This registry is the core of how spans are tracked and managed throughout the application.

### Key Files

- `lib/appsignal/tracer.ex` - Main registry operations
- `lib/appsignal/monitor.ex` - Process monitoring and cleanup
- `lib/appsignal/span.ex` - Span creation and management

## Table Configuration

The ETS table is created in `Appsignal.Tracer.start_link/0` (lib/appsignal/tracer.ex:13):

```elixir
:ets.new(@table, [:named_table, :public, :duplicate_bag])
```

### Why `:duplicate_bag`?

The table uses `:duplicate_bag` instead of `:set` to support multiple spans per process.
This is essential for parent-child span relationships where a single process may have multiple spans open simultaneously:

- A root span (e.g., "http_request")
- One or more child spans (e.g., "database_query", "cache_read")

With `:duplicate_bag`, all spans for a process are stored as multiple entries with the same key (PID), and the last entry represents the current span.

## Storage Format

The table stores tuples in the format: `{pid, span}` where:
- `pid` is the process ID that owns the span
- `span` is either:
  - A `%Appsignal.Span{}` struct
  - The atom `:ignore` (to mark a process as ignored for tracing)

## Core Operations

### Registration

When a span is created, it's registered in the table (lib/appsignal/tracer.ex:229):

```elixir
defp register(%Span{pid: pid} = span) do
  if insert({pid, span}) do
    @monitor.add()
    span
  end
end
```

The registration:
1. Inserts the span into the ETS table
2. Notifies the Monitor to track the process
3. Returns the span for further use

### Lookup

To retrieve spans for a process (lib/appsignal/tracer.ex:74):

```elixir
def lookup(pid) do
  try do
    :ets.lookup(@table, pid)
  rescue
    ArgumentError -> []
  end
end
```

The lookup returns a list of all spans for the PID.
The last entry in the list is the current span.

### Deregistration

When a span is closed, it's removed from the table (lib/appsignal/tracer.ex:238):

```elixir
defp deregister(%Span{pid: pid} = span) do
  try do
    :ets.delete_object(@table, {pid, span})
  rescue
    ArgumentError -> false
  end
end
```

## Process Monitoring

Every process that registers a span is monitored by `Appsignal.Monitor`.
This ensures spans are cleaned up if a process exits without properly closing them.

### Why Monitor All Spans?

Prior to commit c10a608e (2020-12-18), the monitor only tracked specific spans.
However, this could lead to orphaned entries in the registry if a process crashed before closing its spans.

The current implementation monitors every process as soon as it registers any span, ensuring cleanup happens regardless of how the process exits.

### Deletion Delay

When a monitored process exits, there's a 5-second delay before its entries are removed from the registry (lib/appsignal/monitor.ex:4):

```elixir
@deletion_delay Application.compile_env(:appsignal, :deletion_delay, 5_000)
```

This delay provides a grace period for any final processing of the span data before cleanup.

## Performance Optimizations

### Removing Redundant Checks (af402113, 2023-06-20)

The original implementation checked if the registry was running before every operation:

```elixir
if running?() do
  :ets.lookup(@table, pid)
end
```

This was replaced with error handling:

```elixir
try do
  :ets.lookup(@table, pid)
rescue
  ArgumentError -> []
end
```

**Why?**
- The `running?/0` check required a `Process.whereis/1` call for every operation
- When the registry is running (99.9% of the time), this check is redundant overhead
- Using try-rescue handles the rare case where the registry is down without penalizing the common case

This optimization applies to:
- `lookup/1` (commit 25280d58)
- `insert/1` (commit 40933e9b)
- `delete/1` (commit 40933e9b)
- `deregister/1` (commit 40933e9b)

### Impact

The optimization significantly reduced the number of reductions in instrumentation code, particularly for `Appsignal.Instrumentation.instrument/3`, which was creating multiple spans per request.

## The Ignore Pattern

Processes can be marked as "ignored" to prevent span tracking.
This is useful for background processes or operations that shouldn't be traced.

When a process is ignored (lib/appsignal/tracer.ex:183):

```elixir
def ignore(pid) do
  delete(pid)
  insert({pid, :ignore}) && @monitor.add()
  :ok
end
```

The ignore marker:
1. Deletes any existing spans for the process
2. Inserts `{pid, :ignore}` to mark the process as ignored
3. Monitors the process so the ignore marker is cleaned up when it exits

Future span creation attempts check for this marker (lib/appsignal/tracer.ex:252):

```elixir
defp ignored?([{_pid, :ignore}]), do: true
```

## Cross-Process Span Passing

### The Problem

Some frameworks (like Ash) spawn processes internally, making it difficult to maintain parent-child span relationships across process boundaries.

### The Solution: `register_current/1`

Added in commit 362167c4 (2023-09-26), this function allows passing a span from one process to another (lib/appsignal/tracer.ex:212):

```elixir
def register_current(span) do
  register(%{span | pid: self()})
end
```

**Usage Example:**

```elixir
parent = Appsignal.Tracer.current_span()

list
|> Task.async_stream(fn item ->
  Appsignal.Tracer.register_current(parent)
  # Now the task can create child spans of parent
end)
|> Stream.run()
```

The function:
1. Takes an existing span
2. Updates its PID to the current process
3. Registers it in the current process's context

This allows async work to continue tracing under the same parent span.

## Monitor Synchronization

The Monitor periodically synchronizes its list of monitored PIDs with the actual process monitors (lib/appsignal/monitor.ex:43):

```elixir
def handle_info(:sync, _monitors) do
  schedule_sync()
  pids = MapSet.new(monitored_pids())
  {:noreply, pids}
end
```

This happens every 60 seconds by default (`@sync_interval`).

**Why?**
This synchronization ensures the Monitor's internal state stays consistent with the actual Erlang process monitors, recovering from any potential state drift.

## Avoiding Duplicate Monitors

The Monitor maintains a MapSet of monitored PIDs and only creates a monitor if the PID isn't already being monitored (lib/appsignal/monitor.ex:24):

```elixir
def handle_cast({:monitor, pid}, monitors) do
  if MapSet.member?(monitors, pid) do
    {:noreply, monitors}
  else
    Process.monitor(pid)
    {:noreply, MapSet.put(monitors, pid)}
  end
end
```

This prevents creating multiple monitors for the same process when it registers multiple spans.

## Design Rationale Summary

| Decision | Rationale |
|----------|-----------|
| ETS table | Fast, concurrent access from any process |
| `:duplicate_bag` | Support multiple spans per process (parent-child relationships) |
| Monitor all processes | Ensure cleanup even if process crashes |
| Try-rescue over pre-checks | Optimize for the common case (registry running) |
| 5-second deletion delay | Grace period for final span processing |
| Ignore pattern | Allow processes to opt out of tracing |
| `register_current/1` | Enable span passing across process boundaries |

## Historical Context

The registry implementation has evolved significantly:

1. **Initial implementation**: Basic ETS table with `:duplicate_bag`
2. **December 2020** (c10a608e): Added monitoring for all registered spans
3. **February 2022** (fe04cfa8): Added ability to ignore specific processes
4. **June 2023** (af402113): Major performance optimization removing redundant checks
5. **September 2023** (362167c4): Added cross-process span passing

Each change was driven by real-world usage patterns and performance profiling.
