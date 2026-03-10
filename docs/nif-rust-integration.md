# NIF and Rust Agent Integration

The Appsignal Elixir integration communicates with the Rust-based AppSignal agent through a Native Implemented Function (NIF).
This document explains the architecture, design decisions, and implementation details of this integration layer.

## Overview

AppSignal's core agent is written in Rust and provides a C API (`libappsignal.a`).
The Elixir integration uses Erlang NIFs to bridge Elixir code with this C API, allowing direct calls from Elixir to the Rust agent with minimal overhead.

### Key Files

- `lib/appsignal/nif.ex` - Elixir module that loads and wraps the NIF
- `c_src/appsignal_extension.c` - C code that implements the NIF layer
- `Makefile` - Build system for compiling the C extension
- `priv/appsignal_extension.so` - Compiled shared library (generated)
- `priv/libappsignal.a` - Rust agent static library

## Architecture

```
┌──────────────────┐
│  Elixir Code     │  (e.g., Appsignal.Span.create_root/3)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Appsignal.Nif   │  (Elixir NIF wrapper)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  appsignal_      │  (C NIF implementation)
│  extension.c     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  libappsignal.a  │  (Rust agent with C API)
└──────────────────┘
```

## NIF Loading

The NIF is loaded automatically when the `Appsignal.Nif` module is first used (lib/appsignal/nif.ex:13):

```elixir
@on_load :init

def init do
  path = :filename.join(:code.priv_dir(:appsignal), ~c"appsignal_extension")

  case :erlang.load_nif(path, 1) do
    :ok ->
      :ok

    {:error, {:load_failed, reason}} ->
      arch = :erlang.system_info(:system_architecture)

      IO.warn(
        "Error loading NIF (Is your operating system (#{arch}) supported? ...
      )

      :ok
  end
end
```

### Why Loading Always Returns `:ok`

Even if the NIF fails to load, `init/0` returns `:ok`.
This allows the application to start without the NIF, which is useful for:

1. **Testing without the agent** - Tests can use fake implementations
2. **Unsupported platforms** - The app won't crash on platforms where the agent isn't available
3. **Development** - Easier to work on code without a full agent installation

The package checks `Appsignal.Nif.loaded?()` at runtime to determine if the NIF is available.

## Fallback Implementations

All NIF functions have fallback implementations (lib/appsignal/nif.ex:217-401) that are used when the NIF fails to load:

```elixir
def _create_root_span(_namespace) do
  {:ok, make_ref()}
end

def _set_span_name(_reference, _name) do
  :ok
end
```

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

c_src/appsignal_extension.c:136-139:
```c
static void destruct_appsignal_data(ErlNifEnv *UNUSED(env), void *arg) {
  data_ptr *ptr = (data_ptr *)arg;
  appsignal_free_data(ptr->data);
}
```

**2. `appsignal_span_type`** - For span references

Each span created in the Rust agent returns a pointer wrapped in an Erlang resource.
This reference is passed back to the NIF for subsequent operations on the span.

c_src/appsignal_extension.c:141-144:
```c
static void destruct_appsignal_span(ErlNifEnv *UNUSED(env), void *arg) {
  span_ptr *ptr = (span_ptr *)arg;
  appsignal_free_span(ptr->span);
}
```

### Resource Lifecycle Example

```elixir
# Elixir creates a span
{:ok, span_ref} = Appsignal.Nif.create_root_span("http_request")
# span_ref is an opaque Erlang reference

# Elixir passes the reference back to set attributes
Appsignal.Nif.set_span_name(span_ref, "HomeController#index")

# When span_ref goes out of scope and is GC'd,
# destruct_appsignal_span() is called automatically
```

## Data Encoding

The `appsignal_data_type` resource supports building complex nested structures (c_src/appsignal_extension.c:218-232):

```c
static ERL_NIF_TERM _data_map_new(ErlNifEnv* env, ...) {
  ptr = enif_alloc_resource(appsignal_data_type, sizeof(data_ptr));
  ptr->data = appsignal_data_map_new();
  // ...
}
```

The data API supports:
- Maps: `appsignal_data_map_set_string()`, `appsignal_data_map_set_integer()`, etc.
- Arrays: `appsignal_data_array_append_string()`, `appsignal_data_array_append_integer()`, etc.
- Nested structures: `appsignal_data_map_set_data()` for adding maps/arrays inside other maps/arrays

Elixir code uses `Appsignal.Utils.DataEncoder.encode/1` to convert Elixir terms into this format before passing them to the NIF.

## Atom Creation Optimization (5ef6adb1, 2023-05-23)

Originally, the C code created atoms on every call:

```c
return enif_make_tuple2(env, enif_make_atom(env, "ok"), value);
```

This was optimized to create atoms once during NIF loading (c_src/appsignal_extension.c:975-1010):

```c
static int on_load(ErlNifEnv* env, ...) {
  // ...
  ok_atom = enif_make_atom(env, "ok");
  error_atom = enif_make_atom(env, "error");
  sample_atom = enif_make_atom(env, "sample");
  no_sample_atom = enif_make_atom(env, "no_sample");
  true_atom = enif_make_atom(env, "true");
  false_atom = enif_make_atom(env, "false");
  // ...
}
```

Then use them in functions:

```c
return enif_make_tuple2(env, ok_atom, value);
```

**Why?**

According to Erlang's erl_nif documentation, atoms should be created during load time rather than at runtime.
This improves performance by avoiding repeated atom table lookups and is considered a best practice for NIFs.

## Build System

The Makefile (Makefile:1-51) handles platform-specific linking requirements.

### Key Build Steps

1. **Find Erlang headers** - Uses `erl -eval` to locate the Erlang installation
2. **Link libappsignal.a** - The Rust agent is statically linked
3. **Platform-specific flags**:
   - **Linux**: `--whole-archive` to force linking all symbols, even unused ones
   - **macOS**: `-dynamiclib` with explicit `-U` flags for symbols resolved at runtime
   - **FreeBSD**: Similar to Linux but without `-static-libgcc`

### Why `--whole-archive` on Linux?

The Rust agent exports C symbols that the linker might consider "unused" if it only looks at direct calls from the C extension.
Using `--whole-archive` forces all symbols from `libappsignal.a` to be included, ensuring the agent is fully linked.

### Why `-Wl,-U` on macOS?

macOS's linker requires explicit marking of undefined symbols that will be resolved at runtime.
The NIF uses Erlang NIF API functions (like `enif_make_atom`) that don't exist in the extension itself—they're provided by the Erlang VM when the NIF is loaded.

Example (Makefile:28-42):
```makefile
LDFLAGS += -dynamiclib -Wl,-fatal_warnings \
  -Wl,-U,_enif_alloc_resource, \
  -Wl,-U,_enif_get_double \
  -Wl,-U,_enif_get_int \
  # ...
```

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

## Common NIF Functions

### Span Operations

- `create_root_span(namespace)` - Create a root span
- `create_root_span_with_timestamp(namespace, sec, nsec)` - Create with custom timestamp
- `create_child_span(parent)` - Create a child of an existing span
- `set_span_name(reference, name)` - Set the span's name
- `set_span_namespace(reference, namespace)` - Set the span's namespace
- `set_span_attribute_*(reference, key, value)` - Set attributes (string, int, bool, double, sql)
- `set_span_sample_data(reference, key, value)` - Attach sample data
- `add_span_error(reference, name, message, backtrace)` - Add an error to the span
- `close_span(reference)` - Close the span
- `close_span_with_timestamp(reference, sec, nsec)` - Close with custom timestamp

### Metrics Operations

- `set_gauge(key, value, tags)` - Set a gauge metric
- `increment_counter(key, count, tags)` - Increment a counter
- `add_distribution_value(key, value, tags)` - Add a value to a distribution

### Configuration Operations

- `env_put(key, value)` - Set an environment variable in the agent
- `env_get(key)` - Get an environment variable from the agent
- `env_delete(key)` - Delete an environment variable
- `env_clear()` - Clear all environment variables

### Control Operations

- `start()` - Start the agent
- `stop()` - Stop the agent
- `diagnose()` - Run diagnostics and return a report
- `running_in_container?()` - Check if running in a container
- `loaded?()` - Check if the NIF was successfully loaded

### Logging

- `log(group, severity, format, message, attributes)` - Send a log entry to AppSignal

## Error Handling

The C extension uses `enif_make_badarg(env)` for invalid arguments, which raises an `ArgumentError` in Elixir:

```c
if (argc != 2) {
  return enif_make_badarg(env);
}
```

This is appropriate because:
- Argument errors indicate programmer mistakes (wrong types, wrong arity)
- They should crash the calling process
- The crash will be caught by the supervisor if necessary

## Platform Support

The NIF is compiled for specific platform/architecture combinations.
On startup, if the architecture doesn't match, a helpful error is logged (lib/appsignal.ex:183-200).

The installation system:
1. Downloads the correct `libappsignal.a` for the platform during `mix deps.compile`
2. Compiles the C extension against that library
3. Writes an `install.report` with architecture information
4. Checks the report on startup to detect architecture mismatches

This handles cases where:
- The app is compiled on one machine and deployed to another
- The app runs in a container with a different architecture
- The app is built on macOS but deployed to Linux

## Historical Context

The NIF implementation has remained relatively stable since the initial Elixir integration.
The most significant changes have been:

1. **May 2023** (5ef6adb1): Atom creation optimization
2. **Addition of new span APIs**: As OpenTelemetry features were added to the Rust agent
3. **Removal of transaction API**: Older transaction-based API was replaced by span-based API

The C extension is intentionally kept simple—it's purely a thin translation layer between Elixir and the Rust agent's C API.
All business logic lives either in Elixir (easier to test and modify) or in the Rust agent (shared across all language integrations).
