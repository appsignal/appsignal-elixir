defmodule Appsignal.Phoenix.EventHandler do
  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  @spec attach() :: :ok | {:error, :already_exists}
  def attach do
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
        %{conn: %Plug.Conn{private: %{appsignal_transaction: transaction}}},
        _config
      ) do
    @transaction.start_event(transaction)
  end

  def handle_event([:phoenix, :endpoint, :start], _measurements, _metadata, _config) do
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
      nil,
      0
    )
  end

  def handle_event([:phoenix, :endpoint, :stop], _measurements, _metadata, _config) do
    @transaction.finish_event("call.phoenix_endpoint", "call.phoenix_endpoint", nil, 0)
  end
end
