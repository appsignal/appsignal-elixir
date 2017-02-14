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

    ## Custom instrumentation events

    You might be using your endpoint's `instrument/4` macro to create
    custom instrumentation. If you want those events to become part of
    the AppSignal timeline as well, you need to create a custom
    instrumenter module with the help of
    Appsignal.Phoenix.InstrumenterDSL:

    ```
    defmodule PhoenixApp.CustomInstrumenter do

      import Appsignal.Phoenix.InstrumenterDSL
      instrumenter :phoenix_controller_call
      instrumenter :phoenix_controller_render
      instrumenter :custom_event
      instrumenter :another_custom_event
    end
    ```

    And then, use that instead of the AppSignal instrumenter in your `config.exs`:

    ```
    config :phoenix_app, PhoenixApp.Endpoint,
      instrumenters: [PhoenixApp.CustomInstrumenter]
    ```

    See the [Phoenix integration guide](phoenix.html) for information on
    how to instrument other aspects of Phoenix.
    """

    alias Appsignal.Transaction

    require Logger

    import Appsignal.Phoenix.InstrumenterDSL
    instrumenter :phoenix_controller_call
    instrumenter :phoenix_controller_render

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

    @doc false
    def cleanup_args(args) do
      Map.delete(args, :conn)
    end
  end
end
