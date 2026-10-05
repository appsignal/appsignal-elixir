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

  @deprecated "Since AppSignal for Phoenix 2.3.0, Phoenix instrumentation is up automatically. The `use Appsignal.Phoenix` line is no longer needed and should be removed from your app's endpoint file."
  defmacro __using__(_) do
  end
end
