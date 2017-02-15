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
      maybe_transaction_start_event(args, args)
    end

    @doc false
    def phoenix_controller_call(:stop, _diff, {transaction, args} = res) do
      maybe_transaction_finish_event("phoenix_controller_call", res)

      response = Transaction.finish(transaction)
      if response == :sample do
        Transaction.set_request_metadata(transaction, args[:conn])
      end

      :ok = Transaction.complete(transaction)
    end

    @doc false
    def phoenix_controller_render(:start, _compiled, args) do
      maybe_transaction_start_event(args, args)
    end

    @doc false
    def phoenix_controller_render(:stop, _diff, res) do
      maybe_transaction_finish_event("phoenix_controller_render", res)
    end

    @doc false
    def maybe_transaction_start_event(%Transaction{} = transaction, args) do
      {Transaction.start_event(transaction), args}
    end
    def maybe_transaction_start_event(pid, args) when is_pid(pid) do
      maybe_transaction_start_event(Appsignal.TransactionRegistry.lookup(pid), args)
    end
    def maybe_transaction_start_event(%{conn: %Plug.Conn{} = conn}, args) do
      maybe_transaction_start_event(conn.assigns[:appsignal_transaction], args)
    end
    def maybe_transaction_start_event(%{}, args) do
      maybe_transaction_start_event(self(), args)
    end
    def maybe_transaction_start_event(nil, _), do: nil

    @doc false
    def maybe_transaction_finish_event(_event, nil), do: nil
    def maybe_transaction_finish_event(event, {transaction, args}) do
      Transaction.finish_event(transaction, event, event, args, 0)
    end
  end
end
