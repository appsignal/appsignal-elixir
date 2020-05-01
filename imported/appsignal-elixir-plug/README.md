# Appsignal.Plug

> ⚠️  **NOTE**: Appsignal.Plug is part of an upcoming version of Appsignal for
> Elixir, and hasn't been officially released. Aside from beta testing, we
> recommend using [the current version of AppSignal for Elixir](https://github.com/appsignal/appsignal-elixir/tree/master)
> instead.

AppSignal's Plug instrumentation instruments calls to Plug applications to
gain performance insights and error reporting.

## Installation

To install `Appsignal.Plug` into your Plug application, first add
`:appsignal_plug` to your project's dependencies:

``` elixir
defp deps do
  {:appsignal_plug, github: "appsignal/appsignal-plug"},
end
```

After that, follow the [installation instructions for Appsignal for
Elixir](https://github.com/appsignal/appsignal-elixir/tree/tracing).

Finally, `use Appsignal.Plug` in your application's router module:

``` elixir
defmodule AppsignalPlugExample do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end
end
```
