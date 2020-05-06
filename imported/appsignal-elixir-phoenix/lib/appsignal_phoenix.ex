defmodule Appsignal.Phoenix do
  @moduledoc """
  AppSignal's Phoenix instrumentation instruments calls to Phoenix applications
  to gain performance insights and error reporting.

  ## Installation

  To install `Appsignal.Phoenix` into your Phoenix application, `use
  Appsignal.Phoenix` in your application's endpoint module:

      defmodule AppsignalPhoenixExampleWeb.Endpoint do
        use Phoenix.Endpoint, otp_app: :appsignal_phoenix_example
        use Appsignal.Phoenix

        # ...
      end

  """

  defmacro __using__(_) do
    quote do
      use Appsignal.Plug
    end
  end
end
