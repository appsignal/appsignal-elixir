defmodule Appsignal.Phoenix.EventHandler do
  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  @spec attach() :: :ok | {:error, :already_exists}
  def attach do
    :application.ensure_all_started(:telemetry)

    :telemetry.attach_many(
      "appsignal_phoenix_event_handler",
      [
        [:phoenix, :endpoint, :start],
        [:phoenix, :endpoint, :stop]
      ],
      &Appsignal.Phoenix.EventHandler.handle_event/4,
      nil
    )
  end

  @spec handle_event(list(atom()), map(), map(), any()) :: Appsignal.Transaction.t() | nil
  def handle_event(
        [:phoenix, :endpoint, :start],
        _measurements,
        %{conn: %Plug.Conn{private: %{appsignal_transaction: transaction}} = conn},
        _config
      ) do
    @transaction.set_action(transaction, Appsignal.Plug.extract_action(conn))
    @transaction.start_event(transaction)
  end

  def handle_event([:phoenix, :endpoint, :start], _measurements, %{conn: conn}, _config) do
    @transaction.set_action(Appsignal.Plug.extract_action(conn))
    @transaction.start_event()
  end

  def handle_event(
        [:phoenix, :endpoint, :stop],
        _measurements,
        %{conn: %Plug.Conn{private: %{appsignal_transaction: transaction}}},
        _config
      ) do
    @transaction.finish_event(
      transaction,
      "call.phoenix_endpoint",
      "call.phoenix_endpoint",
      %{},
      0
    )
  end

  def handle_event([:phoenix, :endpoint, :stop], _measurements, _metadata, _config) do
    @transaction.finish_event("call.phoenix_endpoint", "call.phoenix_endpoint", %{}, 0)
  end
end
