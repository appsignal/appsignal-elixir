# Instrumentation and Decorators

The AppSignal Elixir integration provides two ways to instrument code: functional wrappers and compile-time decorators.
This document explains both approaches, their design, and important implementation details.

## Overview

Instrumentation creates spans to track execution time and capture contextual information about code execution.
The integration provides:

1. **Functional instrumentation** - `Appsignal.instrument/2` and friends
2. **Decorator-based instrumentation** - `@decorate` macros for compile-time wrapping

## Functional Instrumentation

The primary instrumentation API is `Appsignal.instrument/2`.
This creates a child span, executes the function, and closes the span.

### Basic Usage

```elixir
Appsignal.instrument("database.query", fn ->
  :timer.sleep(100)
  {:ok, %User{}}
end)
```

### With Category

The 3-arity version allows setting a different category:

```elixir
Appsignal.instrument("SELECT * FROM users", "database", fn ->
  Repo.all(User)
end)
```

This creates a span with:
- Name: `"SELECT * FROM users"`
- Category attribute: `"database"`

### With Span Access

Functions can optionally receive the span to add custom data:

```elixir
Appsignal.instrument("process_order", fn span ->
  Appsignal.Span.set_sample_data(span, "params", %{order_id: 123})
  # ... process order
end)
```

## Root Span Instrumentation

`instrument_root/3` creates a root span (new trace) instead of a child span:

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

## Error Reporting

The integration provides two error reporting patterns: `set_error` and `send_error`.

### `set_error` - Add Error to Existing Span

Adds an error to the current root span.

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

Creates a new root span just for the error.

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

### Concerns

Although the decorators provide a quick way to instrument functions for customers, we generally prefer the use of the instrumentation helpers because they're opaque, easier to understand, and easier to debug when something goes wrong. 

That said, removing the decorators would require users to instrument their functions separately, as there's no other solution for that yet. One way we could resolve part of this issue is taking ownership of the monkey patching that currently happens in the decorator library and building on that, but there might be other ways too.

### Available Decorators

**1. `@decorate instrument()`**

Creates a child span with an auto-generated name.

```elixir
@decorate instrument()
def process(data) do
  # ...
end
```

Generates span named: `"MyModule.process_1"` (module + function + arity)

**2. `@decorate instrument(namespace)`**

Creates a child span with a custom namespace.

```elixir
@decorate instrument(:background_job)
def process(data) do
  # ...
end
```

Generates span with namespace `"background_job"` and name `"MyModule.process_1"`

**3. `@decorate transaction()`**

Creates a root span (new trace) with namespace `"background_job"`.

```elixir
@decorate transaction()
def run_job do
  # ...
end
```

**4. `@decorate transaction(namespace)`**

Creates a root span with a custom namespace.

```elixir
@decorate transaction(:custom_namespace)
def run_task do
  # ...
end
```

**5. `@decorate channel_action()`**

Special decorator for Phoenix channel actions.

```elixir
@decorate channel_action()
def handle_in("ping", _payload, socket) do
  # ...
end
```

Generates span with namespace `"channel"` and name `"MyModule.ping"`
