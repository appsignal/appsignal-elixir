# Configuration System

The AppSignal Elixir integration uses a layered configuration system that merges settings from multiple sources.
This document explains how configuration works, the priority of different sources, and important design decisions.

## Overview

Configuration flows through several stages:

1. **Sources** - Configuration is loaded from multiple sources
2. **Merging** - Sources are merged in priority order
3. **Validation** - Configuration is validated for required values
4. **Storage** - Configuration is stored in the Application environment
5. **Writing** - Configuration is written to the NIF for the Rust agent

## Configuration Sources (Priority Order)

Configuration is loaded from four sources, listed from lowest to highest priority (lib/appsignal/config.ex:51-65):

```elixir
sources = %{
  default: load_from_default(),
  system: load_from_system(),
  file: load_from_application(),
  env: load_from_environment()
}

config =
  sources[:default]
  |> Map.merge(sources[:system])
  |> Map.merge(sources[:file])
  |> Map.merge(sources[:env])
```

### 1. Default Configuration

Hard-coded defaults in the package (lib/appsignal/config.ex:8-42).

Examples:
- `active: false` - AppSignal is inactive by default
- `instrument_ecto: true` - Ecto instrumentation is enabled by default
- `log: "file"` - Logs go to file by default
- `send_params: true` - Request parameters are sent by default

### 2. System Detection

Automatically detected system configuration (lib/appsignal/config.ex:268-285):

**Push API Key Detection:**
```elixir
case System.get_env("APPSIGNAL_PUSH_API_KEY") do
  nil -> config
  _ -> Map.merge(config, %{active: true})
end
```

If `APPSIGNAL_PUSH_API_KEY` is set, AppSignal is automatically activated.

**Heroku Detection:**
```elixir
case Appsignal.System.heroku?() do
  false -> config
  true -> Map.merge(config, %{running_in_container: true, log: "stdout"})
end
```

On Heroku, logs automatically go to stdout instead of a file.

### 3. Application Configuration

Configuration from `config/config.exs` or environment-specific config files (lib/appsignal/config.ex:287-289):

```elixir
# config/config.exs
config :appsignal, :config,
  name: "My App",
  push_api_key: "your-api-key",
  env: :prod
```

Can be a keyword list or a map.

### 4. Environment Variables

Environment variables have the highest priority (lib/appsignal/config.ex:291-376).

**Mapping** (lib/appsignal/config.ex:291-342):
```elixir
@env_to_key_mapping %{
  "APPSIGNAL_ACTIVE" => :active,
  "APPSIGNAL_APP_ENV" => :env,
  "APPSIGNAL_APP_NAME" => :name,
  "APPSIGNAL_PUSH_API_KEY" => :push_api_key,
  # ... many more
}
```

**Type Conversion:**

Environment variables are parsed based on their expected type:

- **Strings** - Used as-is: `APPSIGNAL_APP_NAME`, `APPSIGNAL_HOSTNAME`
- **Booleans** - Parsed as `true` or `false`: `APPSIGNAL_ACTIVE`, `APPSIGNAL_DEBUG`
- **Atoms** - Converted to atoms: `APPSIGNAL_APP_ENV`, `APPSIGNAL_OTP_APP`
- **String lists** - Split on commas: `APPSIGNAL_FILTER_PARAMETERS`, `APPSIGNAL_IGNORE_ACTIONS`
- **Floats** - Parsed as floats: `APPSIGNAL_CPU_COUNT`

Example (lib/appsignal/config.ex:369-376):
```elixir
%{}
|> load_environment(@string_keys, & &1)
|> load_environment(@bool_keys, &true?(&1))
|> load_environment(@atom_keys, &String.to_atom(&1))
|> load_environment(@string_list_keys, &String.split(&1, ","))
|> load_environment(@float_keys, &String.to_float(&1))
```

## Configuration Overrides

After merging all sources, some configuration values trigger automatic overrides (lib/appsignal/config.ex:91-94):

```elixir
defp determine_overrides(config) do
  %{}
  |> Map.merge(skip_session_data_backwards_compatibility(config, config[:skip_session_data]))
end
```

### Backwards Compatibility: `skip_session_data`

The `skip_session_data` option was deprecated in favor of `send_session_data`.
The system handles both for backwards compatibility (lib/appsignal/config.ex:96-115):

- If only `send_session_data` is set, `skip_session_data` is derived from it
- If only `skip_session_data` is set, `send_session_data` is derived from it
- If both are set, `send_session_data` takes precedence
- A deprecation warning is shown if `skip_session_data` is used

## Validation

Configuration is considered valid if it has a non-empty `push_api_key` (lib/appsignal/config.ex:130-143):

```elixir
def valid? do
  :appsignal
  |> Application.get_env(:config)
  |> valid?
end

defp valid?(%{push_api_key: key}) when is_binary(key) do
  !(key
    |> String.trim()
    |> empty?())
end

defp valid?(_config), do: false
```

**Why Only Check the Push API Key?**

The push API key is the only strictly required value.
All other configuration has sensible defaults, so the agent can start without them.
Without a valid push API key, the agent cannot send data to AppSignal, making it pointless to run.

## Active vs. Configured

There's an important distinction between **configured as active** and **actually active**:

### `configured_as_active?/0`

Returns `true` if the `active` config option is set to `true` (lib/appsignal/config.ex:122-124):

```elixir
def configured_as_active? do
  Application.get_env(:appsignal, :config, @default_config)[:active] || false
end
```

### `active?/0`

Returns `true` only if BOTH the config is marked as active AND it's valid (lib/appsignal/config.ex:150-160):

```elixir
def active? do
  :appsignal
  |> Application.get_env(:config, @default_config)
  |> active?
end

defp active?(%{active: true} = config) do
  valid?(config)
end

defp active?(_config), do: false
```

**Why the Distinction?**

This allows users to set `active: true` in development but omit the `push_api_key`.
The agent won't actually start (because `active?/0` returns false), but the configuration intent is clear.

## Performance: Avoiding Duplicate ETS Lookups (47dcbed5, 2023-06-13)

Originally, both `active?/0` and `valid?/0` fetched the configuration independently:

```elixir
def active? do
  config = Application.get_env(:appsignal, :config)
  if config[:active] do
    valid?()  # This fetches the config AGAIN
  end
end
```

This was optimized to pass the already-fetched config to `valid?/1`:

```elixir
def active? do
  :appsignal
  |> Application.get_env(:config, @default_config)
  |> active?
end

defp active?(%{active: true} = config) do
  valid?(config)  # Reuses the config
end
```

**Why?**

`Application.get_env/2` requires an ETS lookup.
When checking if AppSignal is active, doing two lookups is wasteful.
Passing the config forward saves the second lookup.

## Handling Empty Configurations (4ac415f1, 2022-06-14)

Many config helper functions previously used `Application.fetch_env!/2`, which raises if the key doesn't exist.
This caused compilation failures when AppSignal wasn't configured.

All helper functions were changed to use `Application.get_env/3` with defaults:

**Before:**
```elixir
def configured_as_active? do
  Application.fetch_env!(:appsignal, :config).active  # Raises if :config not set
end
```

**After:**
```elixir
def configured_as_active? do
  Application.get_env(:appsignal, :config, @default_config)[:active] || false
end
```

**Why?**

This allows projects to include AppSignal as a dependency without configuring it.
The package doesn't crash during compilation or at runtime—it simply stays inactive.

Affected functions (all in the same commit):
- `configured_as_active?/0`
- `active?/0`
- `request_headers/0`
- `log_file_path/0`
- `ca_file_path/0`

## Writing Configuration to the NIF

Before starting the Rust agent, configuration must be written to it through the NIF (lib/appsignal/config.ex:431-494).

### Why Write to NIF?

The Rust agent runs in a separate process and doesn't have access to Elixir's Application environment.
Configuration must be explicitly passed through the NIF using `Appsignal.Nif.env_put/2`.

Example (lib/appsignal.ex:96-99):
```elixir
{:ok, true} ->
  Appsignal.IntegrationLogger.debug("AppSignal starting.")
  Config.write_to_environment()
  Appsignal.Nif.start()
```

### Configuration Keys

All configuration keys are prefixed with `_APPSIGNAL_` when written to the NIF (lib/appsignal/config.ex:439-493):

```elixir
Nif.env_put("_APPSIGNAL_ACTIVE", to_string(config[:active]))
Nif.env_put("_APPSIGNAL_APP_NAME", to_string(config[:name]))
Nif.env_put("_APPSIGNAL_PUSH_API_KEY", config[:push_api_key] || "")
# ... many more
```

**Why the `_` Prefix?**

The underscore prefix distinguishes AppSignal's internal environment from the system's actual environment variables.
This prevents conflicts and makes it clear these are for the agent, not the host system.

### Type Conversion

All values are converted to strings before passing to the NIF:

- Atoms/booleans: `to_string(config[:active])`
- Lists: `config[:ignore_actions] |> Enum.join(",")`
- Nil values: `config[:push_api_key] || ""`

The Rust agent parses these strings back into the appropriate types.

## Feature Flags

Several boolean configuration options control which integrations are enabled.

### Default-Enabled Integrations

These are `true` by default (lib/appsignal/config.ex:27-31):

- `instrument_ecto: true` - Ecto query instrumentation
- `instrument_finch: true` - Finch HTTP client instrumentation
- `instrument_oban: true` - Oban job instrumentation
- `instrument_tesla: true` - Tesla HTTP client instrumentation
- `instrument_absinthe: true` - Absinthe GraphQL instrumentation

Checked via helper functions (lib/appsignal/config.ex:195-257):

```elixir
def instrument_ecto? do
  case Application.fetch_env(:appsignal, :config) do
    {:ok, value} -> !!Access.get(value, :instrument_ecto, true)
    _ -> true
  end
end
```

**Why Default to True?**

The instrumentation libraries use telemetry attachment, which has minimal overhead if the integration isn't being used.
Defaulting to enabled provides the best out-of-box experience.

### Default-Disabled Integrations

- `enable_error_backend: false` - Error backend for crash reporting
- `enable_minutely_probes: true` - System metrics (CPU, memory)
- `enable_statsd: false` - StatsD server
- `enable_nginx_metrics: false` - Nginx metrics collection

Checked via similar helper functions (lib/appsignal/config.ex:188-193):

```elixir
def error_backend_enabled? do
  case Application.fetch_env(:appsignal, :config) do
    {:ok, value} -> !!Access.get(value, :enable_error_backend, false)
    _ -> false
  end
end
```

## Special Configuration: Oban Error Reporting

The `report_oban_errors` option has three possible values (lib/appsignal/config.ex:223-249):

- `"all"` (default) - Report all Oban errors
- `"discard"` - Only report errors for discarded jobs
- `"none"` or `"false"` - Don't report Oban errors

The config helper normalizes various inputs to these three strings:

```elixir
case to_string(value[:report_oban_errors]) do
  "discard" -> "discard"
  x when x in ["none", "false"] -> "none"
  x when x in ["all", "true", ""] -> "all"
  unknown ->
    Logger.warning("Unknown value #{inspect(unknown)} ...")
    "all"
end
```

**Why Special Handling?**

Oban jobs can fail and be retried multiple times.
Users may want to report only permanently failed (discarded) jobs to reduce noise in AppSignal.

## Log Level Configuration

Log level is determined from multiple possible sources (lib/appsignal/config.ex:504-522):

```elixir
defp log_level(config) do
  case to_string(config[:log_level]) do
    "trace" -> :trace
    "debug" -> :debug
    "info" -> :info
    "warn" -> :warn
    "warning" -> :warn
    "error" -> :error
    _ -> deprecated_log_level(config)
  end
end

defp deprecated_log_level(config) do
  cond do
    config[:transaction_debug_mode] -> :trace
    config[:debug] -> :debug
    true -> :info
  end
end
```

**Priority:**
1. `log_level` (if set and valid)
2. `transaction_debug_mode` (deprecated, sets to `:trace`)
3. `debug` (deprecated, sets to `:debug`)
4. Default to `:info`

## Log File Path

The log file path is computed once and cached (lib/appsignal/config.ex:524-536):

```elixir
def log_file_path do
  case Application.fetch_env(:appsignal, :"$log_file_path") do
    {:ok, value} ->
      value

    :error ->
      config = Application.get_env(:appsignal, :config, %{})
      value = do_log_file_path(config[:log_path])
      Application.put_env(:appsignal, :"$log_file_path", value)
      value
  end
end
```

**Why Cache?**

Log file path computation involves filesystem checks (`FileSystem.writable?/1`).
Caching the result avoids repeated filesystem operations.

**Fallback Behavior:**

If the configured log path isn't writable, the system falls back to the system temp directory with a warning.

## Configuration Sources Tracking

All configuration sources are stored separately for debugging (lib/appsignal/config.ex:75):

```elixir
Application.put_env(:appsignal, :config_sources, sources)
```

This allows tools like `mix appsignal.diagnose` to show exactly where each configuration value came from.

## Key Design Decisions Summary

| Decision | Rationale |
|----------|-----------|
| Layered merging | Allows different deployment strategies (env vars in prod, config files in dev) |
| Only validate push API key | All other config has sensible defaults; key is the only critical value |
| `active?` vs `configured_as_active?` | Allows setting `active: true` without a key for intent clarity |
| Pass config to avoid ETS lookups | Performance optimization for frequently called functions |
| Default to `get_env` not `fetch_env!` | Allows projects to depend on AppSignal without configuring it |
| Write config to NIF | Rust agent needs configuration but can't access Elixir's Application env |
| `_APPSIGNAL_` prefix | Prevents conflicts with system environment variables |
| Cache log file path | Avoid repeated filesystem checks |
| Feature flags default to enabled | Telemetry has minimal overhead; better out-of-box experience |
