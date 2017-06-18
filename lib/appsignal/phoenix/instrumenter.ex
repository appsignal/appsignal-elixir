if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.Instrumenter do
    @moduledoc """
    Phoenix instrumentation hooks

    This module can be used as a Phoenix instrumentation module. Adding
    this module to the list of Phoenix instrumenters will result in the
    `phoenix_controller_call` and `phoenix_controller_render` events to
    become part of your request timeline.

    Add this to your `config.exs`:

    ```
    config :my_app, MyApp.Endpoint,
      instrumenters: [Appsignal.Phoenix.Instrumenter]
    ```

    Note: Channels (`phoenix_channel_join` hook) are currently not
    supported.

    See the [Phoenix integration
    guide](http://docs.appsignal.com/elixir/integrations/phoenix.html) for
    information on how to instrument other aspects of Phoenix.
    """
    @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

    @doc false
    def phoenix_controller_call(:start, _, %{conn: conn} = args) do
      @transaction.set_action(Appsignal.Plug.extract_action(conn))
      {@transaction.start_event, args}
    end

    @doc false
    def phoenix_controller_call(:stop, _diff, {%Appsignal.Transaction{} = transaction, args}) do
      finish_event(transaction, "call.phoenix_controller", args)
    end
    def phoenix_controller_call(:stop, _, _), do: nil

    @doc false
    def phoenix_controller_render(:start, _, args) do
      {@transaction.start_event, args}
    end

    @doc false
    def phoenix_controller_render(:stop, _diff, {%Appsignal.Transaction{} = transaction, args}) do
      finish_event(transaction, "render.phoenix_controller", args)
    end
    def phoenix_controller_render(:stop, _, _), do: nil

    defp finish_event(transaction, name, args) do
      @transaction.finish_event(
        transaction,
        name,
        name,
        Map.delete(args, :conn),
        0
      )
    end
  end
end
