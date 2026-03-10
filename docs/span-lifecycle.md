# Span Lifecycle and Event Handling

This document explains how spans are created, managed, and closed throughout their lifecycle.

## Span Structure

A span is represented by a struct (lib/appsignal/span.ex):

```elixir
defstruct [:reference, :pid]
```

- **reference**: Opaque reference to the Rust agent's span (Erlang resource)
- **pid**: Process ID that owns the span

## Span Creation

### Root Spans

Root spans create a new trace:

```elixir
Span.create_root(namespace, pid)
Span.create_root(namespace, pid, start_time)
```

Calls through to the NIF:

```elixir
def create_root(namespace, pid, start_time \\ nil) do
  case start_time do
    nil ->
      {:ok, reference} = Nif.create_root_span(namespace)
      %Span{reference: reference, pid: pid}

    start_time ->
      {sec, nsec} = normalize_time(start_time)
      {:ok, reference} = Nif.create_root_span_with_timestamp(namespace, sec, nsec)
      %Span{reference: reference, pid: pid}
  end
end
```

### Child Spans

Child spans extend an existing trace:

```elixir
Span.create_child(parent, pid)
Span.create_child(parent, pid, start_time)
```

The parent span's reference is passed to create the child relationship.

## Span Operations

### Setting Attributes

```elixir
Span.set_name(span, "Controller#action")
Span.set_namespace(span, "web")
Span.set_attribute(span, "user.id", 123)
Span.set_sql(span, "SELECT * FROM users")
```

All operations return the span to allow piping:

```elixir
span
|> Span.set_name("UserController#show")
|> Span.set_attribute("user_id", user_id)
|> Span.set_sample_data("params", params)
```

### Adding Errors

```elixir
Span.add_error(span, exception, stacktrace)
Span.add_error(span, kind, reason, stacktrace)
```

Errors are converted to the NIF format and attached to the span.

### Sample Data

Sample data is additional context sent with the span:

```elixir
Span.set_sample_data(span, "params", %{id: 123})
Span.set_sample_data(span, "session_data", %{user_id: 456})
```

This uses `Appsignal.Utils.DataEncoder` to convert Elixir terms to the NIF data format.

## Span Closing

Spans must be explicitly closed:

```elixir
Span.close(span)
Span.close(span, end_time)
```

Closing a span:
1. Finalizes timing information
2. Sends the span data to the Rust agent
3. Frees the NIF resource (via garbage collection)

**Important:** Spans should always be closed in an `after` block:

```elixir
span = Tracer.create_span("http_request")

try do
  do_work()
after
  Tracer.close_span(span)
end
```

## Time Handling

Spans can use custom timestamps for start and end times.
Times are normalized to seconds and nanoseconds:

```elixir
defp normalize_time(time) do
  :erlang.convert_time_unit(time, :native, :second)
  nsec = rem(:erlang.convert_time_unit(time, :native, :nanosecond), 1_000_000_000)
  {sec, nsec}
end
```

This allows precise timing when instrumenting code that doesn't use wall clock time.

## Nil Handling

Many span functions handle `nil` gracefully:

```elixir
def set_name(nil, _name), do: nil
def set_attribute(nil, _key, _value), do: nil
def add_error(nil, _kind, _reason, _stacktrace), do: nil
```

This allows instrumentation code to work even when AppSignal is inactive:

```elixir
span = if appsignal_active?, do: Span.create_root(...), else: nil
Span.set_name(span, "foo")  # Works even if span is nil
```

## Registry Integration

Spans are registered in the ETS registry (see tracer-registry.md):

```elixir
Tracer.create_span(namespace)
|> Tracer.register()
```

This allows:
- Looking up spans by PID
- Parent-child relationships
- Automatic cleanup on process exit

## Event vs. Span Terminology

Historical note: AppSignal 1.x used "transaction" and "event" terminology.
AppSignal 2.x switched to OpenTelemetry-style "spans".

Some deprecated functions still reference the old terminology for backwards compatibility.

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Return span from operations | Enables piping for fluent API |
| Handle nil spans | Works when AppSignal is inactive |
| Explicit closing | Ensures spans are finalized and sent |
| Custom timestamps | Supports non-wall-clock instrumentation |
| NIF references | Efficient memory management via GC |
