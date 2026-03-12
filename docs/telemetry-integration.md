# Telemetry Integration

AppSignal's framework integrations are built on Elixir's `:telemetry` library, providing standardized event-driven instrumentation.

## Telemetry Overview

`:telemetry` is a lightweight library for emitting and handling events in Elixir applications.
It enables instrumentation without tight coupling between libraries.

## Attachment Pattern

All AppSignal integrations follow this pattern:

```elixir
def attach do
  :telemetry.attach_many(
    "appsignal-integration-name",
    [
      [:library, :operation, :start],
      [:library, :operation, :stop],
      [:library, :operation, :exception]
    ],
    &handle_event/4,
    :ok
  )
end

def handle_event(event_name, measurements, metadata, _config) do
  case event_name do
    [:library, :operation, :start] ->
      # Create span
    [:library, :operation, :stop] ->
      # Close span, add measurements
    [:library, :operation, :exception] ->
      # Add error to span
  end
end
```

## Event Structure

Telemetry events have three components:

1. **Event name** - List of atoms like `[:ecto, :repo, :query]`
2. **Measurements** - Map of numeric values (timings, counts, sizes)
3. **Metadata** - Map of contextual information (query, params, stack)

## Integration Examples

### Ecto

```elixir
:telemetry.attach_many(
  "appsignal-ecto",
  [
    [:appsignal, :ecto_query_repo, :query]
  ],
  &Appsignal.Ecto.handle_event/4,
  :ok
)
```

Measurements: `query_time`, `queue_time`, `decode_time`
Metadata: `query`, `params`, `repo`, `type`

### Oban

```elixir
:telemetry.attach_many(
  "appsignal-oban",
  [
    [:oban, :job, :start],
    [:oban, :job, :stop],
    [:oban, :job, :exception]
  ],
  &Appsignal.Oban.handle_event/4,
  :ok
)
```

Measurements: `duration`, `queue_time`
Metadata: `job` struct, `state`, `reason`

## Why Telemetry?

**Advantages:**

1. **Decoupling** - Libraries emit events without knowing who's listening
2. **Performance** - Zero overhead when no handlers are attached
3. **Composability** - Multiple handlers can process the same event
4. **Standardization** - Common pattern across the Elixir ecosystem

**Example:** Ecto emits query events regardless of whether AppSignal is installed.
If AppSignal is present and active, it attaches handlers to process those events.

## Custom Telemetry Events

Applications can emit custom events for AppSignal to capture:

```elixir
:telemetry.execute(
  [:myapp, :checkout, :complete],
  %{duration: 123},
  %{user_id: 456, cart_total: 99.99}
)
```

Then create a custom handler:

```elixir
defmodule MyApp.AppSignalInstrumentation do
  def attach do
    :telemetry.attach(
      "myapp-appsignal-checkout",
      [:myapp, :checkout, :complete],
      &handle_checkout/4,
      :ok
    )
  end

  def handle_checkout(_event, measurements, metadata, _config) do
    Appsignal.instrument("checkout", fn span ->
      Appsignal.Span.set_attribute(span, "user_id", metadata.user_id)
      Appsignal.Span.set_attribute(span, "cart_total", metadata.cart_total)
    end)
  end
end
```

## Conditional Attachment

Integrations only attach when configured to do so:

```elixir
if Appsignal.Config.instrument_ecto?() do
  Appsignal.Ecto.attach()
end
```

This allows disabling specific integrations without removing the code.

## Testing with Telemetry

Tests can verify telemetry events are emitted:

```elixir
:telemetry.attach(
  "test-handler",
  [:myapp, :event],
  fn event, measurements, metadata, _config ->
    send(self(), {:telemetry_event, event, measurements, metadata})
  end,
  :ok
)

# Execute code that emits event

assert_receive {:telemetry_event, [:myapp, :event], measurements, metadata}
```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Use `:telemetry` for all integrations | Standard pattern across Elixir ecosystem |
| Attach during application start | Ensures events are captured from the beginning |
| Conditional attachment | Allows disabling integrations via configuration |
| Handle start/stop/exception | Captures full lifecycle of operations |

## Resources

- [Telemetry documentation](https://hexdocs.pm/telemetry/)
- [Telemetry guide](https://hexdocs.pm/telemetry/readme.html)
