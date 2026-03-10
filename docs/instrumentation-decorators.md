# Instrumentation and Decorators

The AppSignal Elixir integration provides two ways to instrument code: functional wrappers and compile-time decorators.
This document explains both approaches, their design, and important implementation details.

## Overview

Instrumentation creates spans to track execution time and capture contextual information about code execution.
The integration provides:

1. **Functional instrumentation** - `Appsignal.instrument/2` and friends
2. **Decorator-based instrumentation** - `@decorate` macros for compile-time wrapping

## Functional Instrumentation

The primary instrumentation API is `Appsignal.instrument/2` (lib/appsignal/instrumentation.ex:41-43):

```elixir
def instrument(name, fun) do
  instrument(name, name, fun)
end
```

This creates a child span, executes the function, and closes the span.

### Basic Usage

```elixir
Appsignal.instrument("database.query", fn ->
  :timer.sleep(100)
  {:ok, %User{}}
end)
```

### With Category

The 3-arity version allows setting a different category (lib/appsignal/instrumentation.ex:50-59):

```elixir
Appsignal.instrument("SELECT * FROM users", "database", fn ->
  Repo.all(User)
end)
```

This creates a span with:
- Name: `"SELECT * FROM users"`
- Category attribute: `"database"`

### With Span Access

Functions can optionally receive the span to add custom data (lib/appsignal/instrumentation.ex:133-134):

```elixir
Appsignal.instrument("process_order", fn span ->
  Appsignal.Span.set_sample_data(span, "params", %{order_id: 123})
  # ... process order
end)
```

**Implementation:**

```elixir
defp call_with_optional_argument(fun, _argument) when is_function(fun, 0), do: fun.()
defp call_with_optional_argument(fun, argument) when is_function(fun, 1), do: fun.(argument)
```

The function checks arity using guards and calls appropriately.

## Root Span Instrumentation

`instrument_root/3` creates a root span (new trace) instead of a child span (lib/appsignal/instrumentation.ex:68-83):

```elixir
def instrument_root(namespace, name, fun) do
  span = @tracer.create_span(namespace, nil)  # nil parent = root

  span
  |> @span.set_name(name)
  |> @span.set_attribute("appsignal:category", name)

  result =
    try do
      call_with_optional_argument(fun, span)
    after
      @tracer.close_span(span)
    end

  result
end
```

This is used for:
- Background jobs without an existing trace
- Phoenix channel actions
- Decorator-based transactions

## Closing the Current Span (ee9eb3a9, 2025-03-06)

An important fix changed how spans are closed in `instrument/1` (lib/appsignal/instrumentation.ex:5-18):

**Before:**
```elixir
def instrument(fun) do
  span = @tracer.create_span("background_job", @tracer.current_span)

  result =
    try do
      call_with_optional_argument(fun, span)
    after
      @tracer.close_span(span)  # Close the specific span we created
    end

  result
end
```

**After:**
```elixir
def instrument(fun) do
  span = @tracer.create_span("background_job", @tracer.current_span)

  result =
    try do
      call_with_optional_argument(fun, span)
    after
      @tracer.close_span(@tracer.current_span())  # Close current span
    end

  result
end
```

**Why?**

In Phoenix apps, render functions can be wrapped in `instrument/2` blocks.
The rendering process creates its own spans, which get closed out of order.

If we try to close `span` (the span we created), but it was already closed by nested instrumentation, the root span won't get closed properly and nothing gets reported.

By closing `@tracer.current_span()`, we always close the most recent span, regardless of what happened inside the block.

## Error Reporting

The integration provides two error reporting patterns: `set_error` and `send_error`.

### `set_error` - Add Error to Existing Span

Adds an error to the current root span (lib/appsignal/instrumentation.ex:85-99):

```elixir
def set_error(%_{__exception__: true} = exception, stacktrace) do
  @span.add_error(@tracer.root_span(), exception, stacktrace)
end

def set_error(kind, reason, stacktrace) do
  @span.add_error(@tracer.root_span(), kind, reason, stacktrace)
end
```

**Use case:** Inside a web request or background job that already has a trace

```elixir
try do
  risky_operation()
rescue
  exception ->
    Appsignal.set_error(exception, __STACKTRACE__)
    # Continue handling...
end
```

### `send_error` - Create New Span for Error

Creates a new root span just for the error (lib/appsignal/instrumentation.ex:101-131):

```elixir
def send_error(%_{__exception__: true} = exception, stacktrace, fun) when is_function(fun) do
  @span.create_root("http_request", self())
  |> @span.add_error(exception, stacktrace)
  |> fun.()
  |> @span.close()
end
```

**Use case:** Outside of any existing trace, like error logging hooks

```elixir
Appsignal.send_error(exception, stacktrace, fn span ->
  Appsignal.Span.set_sample_data(span, "context", %{user_id: 123})
end)
```

## Decorator-Based Instrumentation

Decorators provide compile-time instrumentation using the `decorator` package.

### Setup

```elixir
defmodule MyModule do
  use Appsignal.Instrumentation.Decorators

  @decorate instrument()
  def my_function do
    # ...
  end
end
```

### Available Decorators

**1. `@decorate instrument()`**

Creates a child span with an auto-generated name (lib/appsignal/instrumentation/decorators.ex:65-72):

```elixir
@decorate instrument()
def process(data) do
  # ...
end
```

Generates span named: `"MyModule.process_1"` (module + function + arity)

**2. `@decorate instrument(namespace)`**

Creates a child span with a custom namespace (lib/appsignal/instrumentation/decorators.ex:31-41):

```elixir
@decorate instrument(:background_job)
def process(data) do
  # ...
end
```

Generates span with namespace `"background_job"` and name `"MyModule.process_1"`

**3. `@decorate transaction()`**

Creates a root span (new trace) with namespace `"background_job"` (lib/appsignal/instrumentation/decorators.ex:83-85):

```elixir
@decorate transaction()
def run_job do
  # ...
end
```

**4. `@decorate transaction(namespace)`**

Creates a root span with a custom namespace (lib/appsignal/instrumentation/decorators.ex:93-102):

```elixir
@decorate transaction(:custom_namespace)
def run_task do
  # ...
end
```

**5. `@decorate transaction_event()` (Deprecated)**

Equivalent to `@decorate instrument()` (lib/appsignal/instrumentation/decorators.ex:104-106).

**6. `@decorate transaction_event(category)` (Deprecated)**

Creates a child span with a category (lib/appsignal/instrumentation/decorators.ex:114-116).

**7. `@decorate channel_action()`**

Special decorator for Phoenix channel actions (lib/appsignal/instrumentation/decorators.ex:118-126):

```elixir
@decorate channel_action()
def handle_in("ping", _payload, socket) do
  # ...
end
```

Generates span with namespace `"channel"` and name `"MyModule.ping"`

## Decorator Name Generation

Decorator-generated span names follow a specific format.

### Module Name Normalization

The `module_name/1` helper (from `Appsignal.Utils`) converts Elixir module names to string format:

```elixir
Elixir.MyApp.Users.UserController  ->  "MyApp.Users.UserController"
```

### Function Name with Arity

Most decorators append arity to the function name (lib/appsignal/instrumentation/decorators.ex:31-41):

```elixir
defp do_instrument(body, %{module: module, name: name, arity: arity, namespace: namespace}) do
  quote do
    Appsignal.Instrumentation.instrument(
      "#{module_name(unquote(module))}.#{unquote(name)}_#{unquote(arity)}",
      fn span ->
        # ...
      end
    )
  end
end
```

Result: `"MyModule.function_2"` for a function with arity 2

### Why Include Arity?

Including arity distinguishes overloaded functions:

```elixir
@decorate instrument()
def process(item), do: # ...

@decorate instrument()
def process(item, opts), do: # ...
```

Generates: `"MyModule.process_1"` and `"MyModule.process_2"`

## Slashes to Underscores (1d7b7a3f, 2021-08-19)

Originally, decorator-generated names used slashes for arity:

```
"MyModule.function/2"
```

This was changed to underscores:

```
"MyModule.function_2"
```

**Why?**

The Rust agent's OpenTelemetry span API doesn't support slashes in span names.
Slashes have special meaning in the processing API.

**Impact:**

This changed action naming in AppSignal's UI, causing new incidents for existing errors.
It was released as a minor version bump because it's a breaking change in observability.

See: https://docs.appsignal.com/api/event-names.html

## Decorator Context

Decorators receive a context map with information about the decorated function:

```elixir
%{
  module: __MODULE__,    # The module containing the function
  name: :function_name,  # The function name as an atom
  arity: 2,              # The function's arity
  args: [arg1, arg2]     # The function's arguments (for channel_action)
}
```

Different decorators use different parts of this context.

## Compile-Time Configuration

The instrumentation modules use compile-time configuration to allow test fakes (lib/appsignal/instrumentation.ex:2-3):

```elixir
@tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
@span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
```

In tests:

```elixir
# config/test.exs
config :appsignal, appsignal_tracer, Appsignal.Test.Tracer
config :appsignal, appsignal_span, Appsignal.Test.Span
```

This allows injecting fake implementations that track calls instead of creating real spans.

## Helpers Module

`Appsignal.Instrumentation.Helpers` (lib/appsignal/instrumentation/helpers.ex) provides delegated access to instrumentation functions:

```elixir
defmodule Appsignal.Instrumentation.Helpers do
  defdelegate instrument(fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, title, fun), to: Appsignal.Instrumentation
end
```

This module exists for backwards compatibility and to provide a consistent import point.

## Common Patterns

### Manual Instrumentation with Attributes

```elixir
Appsignal.instrument("fetch_user", fn span ->
  Appsignal.Span.set_attribute(span, "user_id", user_id)
  Appsignal.Span.set_attribute(span, "source", "database")
  User.get(user_id)
end)
```

### Conditional Instrumentation

```elixir
if Mix.env() == :prod do
  Appsignal.instrument("expensive_operation", fn ->
    do_expensive_operation()
  end)
else
  do_expensive_operation()
end
```

### Nested Instrumentation

```elixir
Appsignal.instrument("process_batch", fn ->
  Enum.each(items, fn item ->
    Appsignal.instrument("process_item", fn ->
      process(item)
    end)
  end)
end)
```

This creates a parent span `"process_batch"` with multiple child spans `"process_item"`.

### Background Job Instrumentation

```elixir
def perform(args) do
  Appsignal.Instrumentation.instrument_root(
    "background_job",
    "#{__MODULE__}.perform",
    fn ->
      do_work(args)
    end
  )
end
```

## Key Design Decisions Summary

| Decision | Rationale |
|----------|-----------|
| Two APIs (functional & decorators) | Functional for flexibility; decorators for convenience |
| Close current span, not specific span | Handles out-of-order span closing in complex codepaths |
| `set_error` vs `send_error` | Different use cases: within vs. outside existing traces |
| Include arity in decorator names | Distinguishes overloaded functions |
| Slashes to underscores | Compatibility with OpenTelemetry span naming |
| Optional span argument | Balance between convenience and customization |
| Compile-time module configuration | Enables test fakes without runtime overhead |
| Auto-generate names from module/function | Consistency and discoverability in AppSignal UI |

## Backwards Compatibility

Several deprecated patterns exist for users upgrading from older versions:

- `transaction_event` decorators (use `instrument` instead)
- 4-arity `instrument/4` (use 3-arity version)
- The distinction between "transaction" and "event" terminology (now unified as "span")

These remain functional but emit deprecation warnings.
