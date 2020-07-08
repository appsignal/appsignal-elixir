# Appsignal.Phoenix

> ⚠️  **NOTE**: Appsignal.Phoenix is part of an upcoming version of Appsignal
> for Elixir, and hasn't been officially released. Aside from beta testing, we
> recommend using [the current version of AppSignal for
> Elixir](https://github.com/appsignal/appsignal-elixir/tree/main) instead.

AppSignal's Phoenix instrumentation instruments calls to Phoenix applications
to gain performance insights and error reporting.

## Installation

To install `Appsignal.Phoenix` into your Phoenix application, first add
`:appsignal_phoenix` to your project's dependencies:

``` elixir
defp deps do
  {:appsignal_phoenix, "~> 2.0.0-alpha.1"},
end
```

After that, follow the [installation instructions for Appsignal for
Elixir](https://github.com/appsignal/appsignal-elixir/tree/tracing).

Then, `use Appsignal.Phoenix` in your application's endpoint module:

``` elixir
defmodule AppsignalPhoenixExampleWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :appsignal_phoenix_example
  use Appsignal.Phoenix

  # ...
end
```

Finally, `use Appsignal.Phoenix.View` in the `view/0` function in your app's web
module.

``` elixir
defmodule AppsignalPhoenixExampleWeb do
  # ...

  def view do
    quote do
      use Phoenix.View,
        root: "lib/appsignal_phoenix_example_web/templates",
        namespace: AppsignalPhoenixExampleWeb

      use Appsignal.Phoenix.View

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  # ...
end
```
