# Appsignal.Phoenix

> ⚠️  **NOTE**: Appsignal.Phoenix is part of an upcoming version of Appsignal
> for Elixir, and hasn't been officially released. Aside from beta testing, we
> recommend using [the current version of AppSignal for
> Elixir](https://github.com/appsignal/appsignal-elixir/tree/master) instead.

AppSignal's Phoenix instrumentation instruments calls to Phoenix applications
to gain performance insights and error reporting.

## Installation

To install `Appsignal.Phoenix` into your Phoenix application, first add
`:appsignal_phoenix` to your project's dependencies:

``` elixir
defp deps do
  {:appsignal_phoenix, github: "appsignal/appsignal-elixir-phoenix"},
end
```

After that, follow the [installation instructions for Appsignal for
Elixir](https://github.com/appsignal/appsignal-elixir/tree/tracing).

Finally, `use Appsignal.Phoenix` in your application's endpoint module:

``` elixir
defmodule AppsignalPhoenixExampleWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :appsignal_phoenix_example
  use Appsignal.Phoenix

  # ...
end
```
