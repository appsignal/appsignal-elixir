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
    config :phoenix_app, PhoenixApp.Endpoint,
      instrumenters: [Appsignal.Phoenix.Instrumenter]
    ```

    Note: Channels (`phoenix_channel_join` hook) are currently not
    supported.

    See the [Phoenix integration
    guide](http://docs.appsignal.com/elixir/integrations/phoenix.html) for
    information on how to instrument other aspects of Phoenix.
    """

    alias Appsignal.Transaction

    require Logger

    @doc false
    def phoenix_controller_call(:start, _compiled, args) do
      {Transaction.start_event(), args}
    end

    @doc false
    def phoenix_controller_call(:stop, _diff, {%Transaction{} = transaction, %{conn: conn} = args}) do
      Transaction.finish_event(
        transaction,
        "phoenix_controller_call",
        "phoenix_controller_call",
        cleanup_args(args),
        0
      )

      Transaction.try_set_action(transaction, conn)

      response = Transaction.finish(transaction)
      if response == :sample do
        Transaction.set_request_metadata(transaction, conn)
      end

      :ok = Transaction.complete(transaction)
    end

    @doc false
    def phoenix_controller_render(:start, _compiled, args) do
      {Transaction.start_event(), args}
    end

    @doc false
    def phoenix_controller_render(:stop, _diff, nil), do: nil
    def phoenix_controller_render(:stop, _diff, {transaction, args}) do
      Transaction.finish_event(
        transaction,
        "phoenix_controller_render",
        "phoenix_controller_render",
        cleanup_args(args),
        0
      )
    end

    defp cleanup_args(args) do
      Map.delete(args, :conn)
    end
  end
end
