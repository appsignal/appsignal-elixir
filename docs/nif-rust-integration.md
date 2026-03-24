# NIF and Rust Agent Integration

The Appsignal Elixir integration communicates with the Rust-based AppSignal agent through a Native Implemented Function (NIF).
This document explains the architecture, design decisions, and implementation details of this integration layer.

## Overview

AppSignal's core agent is written in Rust and provides a C API.
The Elixir integration uses Erlang NIFs to bridge Elixir code with this C API, allowing direct calls from Elixir to the Rust agent with minimal overhead.

## NIF Loading

The NIF is loaded automatically when the `Appsignal.Nif` module is first used.

### Why Loading Always Returns `:ok`

Even if the NIF fails to load, `init/0` returns `:ok`.
This allows the application to start without the NIF, which is useful for:

1. **Testing without the agent** - Tests can use fake implementations
2. **Unsupported platforms** - The app won't crash on platforms where the agent isn't available
3. **Development** - Easier to work on code without a full agent installation

The package checks `Appsignal.Nif.loaded?()` at runtime to determine if the NIF is available.

## Fallback Implementations

All NIF functions have fallback implementations that are used when the NIF fails to load.

These fallbacks:
- Return appropriate default values (`:ok`, `{:ok, make_ref()}`, etc.)
- Allow the code to run without the NIF
- Enable testing without a full agent installation

## Resource Types

The C extension uses Erlang resource types to manage memory for data structures that live in the Rust agent.

### Why Resource Types?

Resource types provide automatic memory management through Erlang's garbage collector.
When the Erlang reference is GC'd, the associated C destructor is called, freeing the Rust-side memory.

### Two Resource Types

**1. `appsignal_data_type`** - For structured data (maps and arrays)

Used for:
- Tags on metrics (e.g., `%{"host" => "web-1"}`)
- Sample data on spans (e.g., request headers, parameters)
- Error backtraces
- Log attributes

**2. `appsignal_span_type`** - For span references

Each span created in the Rust agent returns a pointer wrapped in an Erlang resource.
This reference is passed back to the NIF for subsequent operations on the span.

## Data Encoding

The `appsignal_data_type` resource supports building complex nested structures.

The data API supports:
- Maps: `appsignal_data_map_set_string()`, `appsignal_data_map_set_integer()`, etc.
- Arrays: `appsignal_data_array_append_string()`, `appsignal_data_array_append_integer()`, etc.
- Nested structures: `appsignal_data_map_set_data()` for adding maps/arrays inside other maps/arrays

Elixir code uses `Appsignal.Utils.DataEncoder.encode/1` to convert Elixir terms into this format before passing them to the NIF.

## Testing Without the NIF

The integration supports running tests without loading the real NIF through compile-time configuration.

### Test Environment Variables

In config/test.exs:
```elixir
config :appsignal, appsignal_span, Appsignal.Test.Span
config :appsignal, appsignal_nif, Appsignal.Test.Nif
```

This allows tests to inject fake implementations that:
- Record calls instead of sending data to the agent
- Return predictable values for assertions
- Run faster without native code execution

### Fake NIF Implementation

See `test/support/appsignal/fake_nif.ex` for an example fake implementation that tracks calls and returns canned responses.

## Error Handling

The C extension uses `enif_make_badarg(env)` for invalid arguments, which raises an `ArgumentError` in Elixir:

This is appropriate because:
- Argument errors indicate programmer mistakes (wrong types, wrong arity)
- They should crash the calling process
- The crash will be caught by the supervisor if necessary

## Platform Support

The NIF is compiled for specific platform/architecture combinations.
On startup, if the architecture doesn't match, a helpful error is logged.

The installation system:
1. Downloads the correct `libappsignal.a` for the platform during `mix deps.compile`
2. Compiles the C extension against that library
3. Writes an `install.report` with architecture information
4. Checks the report on startup to detect architecture mismatches

This handles cases where:
- The app is compiled on one machine and deployed to another
- The app runs in a container with a different architecture
- The app is built on macOS but deployed to Linux
