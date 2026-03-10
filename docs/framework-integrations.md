# Framework Integrations

AppSignal integrates with popular Elixir frameworks through telemetry attachments.
All integrations follow a similar pattern and can be toggled via configuration.

## Integration Pattern

All framework integrations:
1. Attach to telemetry events during application startup
2. Can be disabled via configuration (most are enabled by default)
3. Create spans for operations with relevant metadata
4. Extract errors and context from telemetry metadata

## Available Integrations

### Ecto (Database Queries)

**Config:** `instrument_ecto: true` (default)
**Module:** `Appsignal.Ecto`
**Telemetry events:** `[:appsignal, :*, :repo, :query]`

Creates spans for database queries with:
- Query SQL
- Query time
- Queue time
- Decode time

### Oban (Background Jobs)

**Config:** `instrument_oban: true` (default), `report_oban_errors: "all"/"discard"/"none"`
**Module:** `Appsignal.Oban`
**Telemetry events:** `[:oban, :job, :start]`, `[:oban, :job, :stop]`, `[:oban, :job, :exception]`

Creates root spans for job execution with:
- Job worker name
- Job args
- Job queue
- Execution time
- Error handling (configurable)

### Finch (HTTP Client)

**Config:** `instrument_finch: true` (default)
**Module:** `Appsignal.Finch`
**Telemetry events:** `[:finch, :request, :start]`, `[:finch, :request, :stop]`, `[:finch, :request, :exception]`

Creates spans for HTTP requests with:
- Request URL
- HTTP method
- Response status
- Request/response time

### Tesla (HTTP Client)

**Config:** `instrument_tesla: true` (default)
**Module:** `Appsignal.Tesla`
**Telemetry events:** Tesla middleware

Creates spans for HTTP requests similar to Finch.

### Absinthe (GraphQL)

**Config:** `instrument_absinthe: true` (default)
**Module:** `Appsignal.Absinthe`
**Telemetry events:** `[:absinthe, :*]`

Creates spans for GraphQL operations with:
- Operation name
- Query/mutation type
- Field resolution timing

## Telemetry-Based Architecture

All integrations use Elixir's `:telemetry` library for event-driven instrumentation:

```elixir
:telemetry.attach_many(
  "appsignal-ecto",
  [[:appsignal, repo, :query]],
  &Appsignal.Ecto.handle_event/4,
  :ok
)
```

This allows zero-overhead instrumentation when AppSignal isn't active.

## Configuration

Integrations are automatically attached during application start (lib/appsignal.ex:28-50):

```elixir
if Config.instrument_ecto?() do
  Appsignal.Ecto.attach()
end

if Config.instrument_oban?() do
  Appsignal.Oban.attach()
end
# ...
```

Disable an integration:

```elixir
# config/config.exs
config :appsignal, :config,
  instrument_ecto: false,
  instrument_oban: false
```

## Why Default to Enabled?

Telemetry attachments have minimal overhead when not in use.
Events are only emitted if something is listening.
Defaulting to enabled provides the best out-of-box experience.

## Adding Custom Integrations

Follow the same pattern for custom instrumentation:

```elixir
defmodule MyApp.CustomInstrumentation do
  def attach do
    :telemetry.attach_many(
      "myapp-custom",
      [[:myapp, :custom, :event]],
      &handle_event/4,
      :ok
    )
  end

  def handle_event(_event_name, measurements, metadata, _config) do
    # Create spans, add metadata
  end
end
```

Then attach during application start.
