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

Configuration is loaded from four sources, listed from lowest to highest priority.

### 1. Default Configuration

Hard-coded defaults in the package.

Examples:
- `active: false` - AppSignal is inactive by default
- `instrument_ecto: true` - Ecto instrumentation is enabled by default
- `log: "file"` - Logs go to file by default
- `send_params: true` - Request parameters are sent by default

### 2. System Detection

Automatically detected system configuration.
If `APPSIGNAL_PUSH_API_KEY` is set, AppSignal is automatically activated.

### 3. Application Configuration

Configuration from `config/config.exs` or environment-specific config files:287-289):
Can be a keyword list or a map.

### 4. Environment Variables

Environment variables have the highest priority.

**Type Conversion:**

Environment variables are parsed based on their expected type:

- **Strings** - Used as-is: `APPSIGNAL_APP_NAME`, `APPSIGNAL_HOSTNAME`
- **Booleans** - Parsed as `true` or `false`: `APPSIGNAL_ACTIVE`, `APPSIGNAL_DEBUG`
- **Atoms** - Converted to atoms: `APPSIGNAL_APP_ENV`, `APPSIGNAL_OTP_APP`
- **String lists** - Split on commas: `APPSIGNAL_FILTER_PARAMETERS`, `APPSIGNAL_IGNORE_ACTIONS`
- **Floats** - Parsed as floats: `APPSIGNAL_CPU_COUNT`

## Configuration Overrides

After merging all sources, some configuration values trigger automatic overrides.

### Backwards Compatibility: `skip_session_data`

The `skip_session_data` option was deprecated in favor of `send_session_data`.
The system handles both for backwards compatibility.

- If only `send_session_data` is set, `skip_session_data` is derived from it
- If only `skip_session_data` is set, `send_session_data` is derived from it
- If both are set, `send_session_data` takes precedence
- A deprecation warning is shown if `skip_session_data` is used

## Validation

Configuration is considered valid if it has a non-empty `push_api_key`.

**Why Only Check the Push API Key?**

The push API key is the only strictly required value.
All other configuration has sensible defaults, so the agent can start without them.
Without a valid push API key, the agent cannot send data to AppSignal, making it pointless to run.

## Active vs. Configured

There's an important distinction between **configured as active** and **actually active**:

### `configured_as_active?/0`

Returns `true` if the `active` config option is set to `true` (lib/appsignal/config.ex:122-124):

### `active?/0`

Returns `true` only if BOTH the config is marked as active AND it's valid.

**Why the Distinction?**

This allows users to set `active: true` in development but omit the `push_api_key`.
The agent won't actually start (because `active?/0` returns false), but the configuration intent is clear.

## Writing Configuration to the NIF

Before starting the Rust agent, configuration must be written to it through the NIF.

### Why Write to NIF?

The Rust agent runs in a separate process and doesn't have access to Elixir's Application environment.
Configuration must be explicitly passed through the NIF using `Appsignal.Nif.env_put/2`.

### Configuration Keys

All configuration keys are prefixed with `_APPSIGNAL_` when written to the NIF.

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

These are `true` by default:

- `instrument_ecto: true` - Ecto query instrumentation
- `instrument_finch: true` - Finch HTTP client instrumentation
- `instrument_oban: true` - Oban job instrumentation
- `instrument_tesla: true` - Tesla HTTP client instrumentation
- `instrument_absinthe: true` - Absinthe GraphQL instrumentation

**Why Default to True?**

The instrumentation libraries use telemetry attachment, which has minimal overhead if the integration isn't being used.
Defaulting to enabled provides the best out-of-box experience.

### Default-Disabled Integrations

- `enable_error_backend: false` - Error backend for crash reporting
- `enable_minutely_probes: true` - System metrics (CPU, memory)
- `enable_statsd: false` - StatsD server
- `enable_nginx_metrics: false` - Nginx metrics collection

## Special Configuration: Oban Error Reporting

The `report_oban_errors` option has three possible values (lib/appsignal/config.ex:223-249):

- `"all"` (default) - Report all Oban errors
- `"discard"` - Only report errors for discarded jobs
- `"none"` or `"false"` - Don't report Oban errors

**Why Special Handling?**

Oban jobs can fail and be retried multiple times.
Users may want to report only permanently failed (discarded) jobs to reduce noise in AppSignal.
