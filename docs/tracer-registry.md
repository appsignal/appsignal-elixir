# Tracer Registry (ETS Table)

The Appsignal Elixir integration uses an ETS table as a registry to track spans across processes.
This document explains the design decisions and implementation details.

## Overview

The tracer registry is implemented as an ETS table named `$appsignal_registry` that maintains a mapping of process PIDs to their active spans.
This registry is the core of how spans are tracked and managed throughout the application.

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

When a span is created, it's registered in the table.
The registration:

1. Inserts the span into the ETS table
2. Notifies the Monitor to track the process
3. Returns the span for further use

### Lookup

The lookup returns a list of all spans for the PID when retrieving Spans for a process.
The last entry in the list is the current span.

### Deregistration

When a span is closed, it's deregistered, and removed from the ETS table.

## Process Monitoring

Every process that registers a span is monitored by `Appsignal.Monitor`.

The monitor removes the span from the ETS table, even if the process exists without properly closing the span.
If that didn't happen, the span would remain in the table, which would cause a small memory leak.

### Deletion Delay

When a monitored process exits, there's a 5-second delay before its entries are removed from the registry.
This delay provides a grace period for any final processing of the span data before cleanup.

## The Ignore Pattern

Processes can be marked as "ignored" to prevent span tracking.
This is useful for background processes or operations that should no longer be tracked.

The ignore marker:
1. Deletes any existing spans for the process
2. Inserts `{pid, :ignore}` to mark the process as ignored
3. Monitors the process so the ignore marker is cleaned up when it exits

## Cross-Process Span Passing

### The Problem

Some frameworks (like Ash) spawn processes internally, making it difficult to maintain parent-child span relationships across process boundaries.

### The Solution: `register_current/1`

The `register_current/1` function allows passing a span from one process to another.

The function:
1. Takes an existing span
2. Updates its PID to the current process
3. Registers it in the current process's context

This allows async work to continue tracing under the same parent span.

## Monitor Synchronization

The Monitor periodically synchronizes its list of monitored PIDs with the actual process monitors.
This happens every 60 seconds by default (`@sync_interval`).

**Why?**
This synchronization ensures the Monitor's internal state stays consistent with the actual Erlang process monitors, recovering from any potential state drift.

## Avoiding Duplicate Monitors

The Monitor maintains a MapSet of monitored PIDs and only creates a monitor if the PID isn't already being monitored.
This prevents creating multiple monitors for the same process when it registers multiple spans.
