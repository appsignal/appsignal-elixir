# Appsignal.Plug

AppSignal's Plug instrumentation instruments calls to Plug applications to
gain performance insights and error reporting.

## Installation

To install `Appsignal.Plug` into your Plug application, first add
`:appsignal_plug` to your project's dependencies:

``` elixir
defp deps do
  {:appsignal_plug, "~> 2.0"}
end
```

After that, follow the [installation instructions for Appsignal for
Elixir](https://docs.appsignal.com/elixir/installation/).

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

For more information, check out the [Integrating AppSignal into
Plug](https://docs.appsignal.com/elixir/integrations/plug.html) guide.
