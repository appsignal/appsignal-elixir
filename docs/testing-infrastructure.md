# Testing Infrastructure

AppSignal provides test helpers and fake implementations to enable testing without the real agent.

## Test Configuration

In `config/test.exs`, inject fake implementations:

```elixir
config :appsignal,
  appsignal_tracer: Appsignal.Test.Tracer,
  appsignal_span: Appsignal.Test.Span,
  appsignal_nif: Appsignal.Test.Nif,
  appsignal_monitor: Appsignal.Test.Monitor
```

These are compile-time settings that replace the real implementations throughout the codebase.

## Fake Implementations

### Appsignal.Test.Tracer

Tracks tracer calls in an Agent:

```elixir
# In tests
Appsignal.Test.Tracer.start_link()

Appsignal.Tracer.create_span("http_request")

assert {:ok, [{namespace}]} = Appsignal.Test.Tracer.get(:create_span)
```

Stored operations:
- `:create_span`
- `:close_span`
- `:lookup`
- `:current_span`
- `:root_span`

### Appsignal.Test.Span

Tracks span operations:

```elixir
Appsignal.Test.Span.start_link()

span = %Appsignal.Span{reference: make_ref(), pid: self()}
Appsignal.Span.set_name(span, "Controller#action")

assert {:ok, [{^span, "Controller#action"}]} =
  Appsignal.Test.Span.get(:set_name)
```

Stored operations:
- `:create_root`
- `:create_child`
- `:set_name`
- `:set_namespace`
- `:set_attribute`
- `:set_sample_data`
- `:add_error`
- `:close`

### Appsignal.Test.Nif

Tracks NIF calls without calling into Rust:

```elixir
Appsignal.Test.Nif.start_link()

Appsignal.Nif.start()

assert {:ok, [[]]} = Appsignal.Test.Nif.get(:start)
```

Returns dummy values (`:ok`, `{:ok, make_ref()}`) appropriate for each function.

### Appsignal.Test.Monitor

Tracks monitor operations:

```elixir
Appsignal.Test.Monitor.start_link()

Appsignal.Monitor.add()

assert {:ok, [{pid}]} = Appsignal.Test.Monitor.get(:add)
```

## Test Helpers

### Agent-Based Storage

All fake implementations use Agents to store calls:

```elixir
defmodule Appsignal.Test.Tracer do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_span(namespace) do
    Agent.update(__MODULE__, fn state ->
      calls = Map.get(state, :create_span, [])
      Map.put(state, :create_span, calls ++ [{namespace}])
    end)
  end

  def get(key) do
    case Agent.get(__MODULE__, &Map.fetch(&1, key)) do
      {:ok, calls} -> {:ok, calls}
      :error -> :error
    end
  end
end
```

### Setup Helpers

Common test setup:

```elixir
setup do
  {:ok, _} = start_supervised(Appsignal.Test.Tracer)
  {:ok, _} = start_supervised(Appsignal.Test.Span)
  {:ok, _} = start_supervised(Appsignal.Test.Nif)
  {:ok, _} = start_supervised(Appsignal.Test.Monitor)
  :ok
end
```

Or use a shared helper module:

```elixir
defmodule MyAppTest do
  use ExUnit.Case
  import AppsignalTestHelpers

  setup :setup_appsignal_test
end
```

## Testing Instrumentation

### Verify Spans Are Created

```elixir
test "creates a span for user lookup" do
  MyApp.Users.find(123)

  assert {:ok, calls} = Appsignal.Test.Tracer.get(:create_span)
  assert [{namespace}] = calls
  assert namespace == "background_job"
end
```

### Verify Span Names and Attributes

```elixir
test "sets span name and attributes" do
  MyApp.process_order(order_id: 123)

  assert {:ok, name_calls} = Appsignal.Test.Span.get(:set_name)
  assert [{_span, "Order.process"}] = name_calls

  assert {:ok, attr_calls} = Appsignal.Test.Span.get(:set_attribute)
  assert [{_span, "order_id", 123}] in attr_calls
end
```

### Verify Error Handling

```elixir
test "adds error to span" do
  assert_raise RuntimeError, fn ->
    MyApp.failing_operation()
  end

  assert {:ok, error_calls} = Appsignal.Test.Span.get(:add_error)
  assert [{_span, _kind, _reason, _stacktrace}] = error_calls
end
```

## Disabling AppSignal in Tests

To completely disable AppSignal:

```elixir
# config/test.exs
config :appsignal, :config,
  active: false
```

This prevents any instrumentation from running, which is faster but provides less test coverage.

## Testing Framework Integrations

For testing framework integrations, use real telemetry events:

```elixir
test "instruments Ecto queries" do
  :telemetry.execute(
    [:myapp, :repo, :query],
    %{query_time: 1000},
    %{query: "SELECT * FROM users"}
  )

  assert {:ok, calls} = Appsignal.Test.Tracer.get(:create_span)
  assert length(calls) > 0
end
```

## Key Testing Principles

| Principle | Implementation |
|-----------|----------------|
| Compile-time injection | Use `Application.compile_env/3` for test doubles |
| Agent-based storage | Track calls in Agents for easy assertion |
| Return appropriate types | Fake implementations return correct types/structures |
| Supervisor integration | Start test helpers under test's supervisor tree |
| Minimal stubbing | Only stub what's necessary for the test |

## Debugging Tests

Enable logging to see what's happening:

```elixir
# config/test.exs
config :logger, level: :debug

config :appsignal, :config,
  debug: true
```

Check fake implementation state:

```elixir
Appsignal.Test.Tracer.get(:create_span)
|> IO.inspect(label: "Create span calls")
```

## Common Pitfalls

1. **Forgetting to start test helpers** - Always start them in setup
2. **Not resetting state between tests** - Use `start_supervised/1` which stops on test end
3. **Checking for exact matches** - Use pattern matching for flexible assertions
4. **Testing real NIF** - Ensure test config injects fakes

## Example Test Module

```elixir
defmodule MyApp.FeatureTest do
  use ExUnit.Case

  setup do
    {:ok, _} = start_supervised(Appsignal.Test.Tracer)
    {:ok, _} = start_supervised(Appsignal.Test.Span)
    {:ok, _} = start_supervised(Appsignal.Test.Nif)
    {:ok, _} = start_supervised(Appsignal.Test.Monitor)
    :ok
  end

  test "instruments feature usage" do
    MyApp.Feature.run()

    # Verify span creation
    assert {:ok, [{namespace}]} = Appsignal.Test.Tracer.get(:create_span)
    assert namespace == "background_job"

    # Verify span name
    assert {:ok, [{_span, name}]} = Appsignal.Test.Span.get(:set_name)
    assert name == "Feature.run"

    # Verify span closing
    assert {:ok, [_span]} = Appsignal.Test.Tracer.get(:close_span)
  end
end
```
