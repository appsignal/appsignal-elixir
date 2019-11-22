defmodule Appsignal.Phoenix.EventHandler do
  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  def handle_event([:phoenix, :endpoint, :start], _measurements, _metadata, _config) do
    @transaction.start_event()
  end

  def handle_event([:phoenix, :endpoint, :stop], _measurements, _metadata, _config) do
    @transaction.finish_event(
      "call.phoenix_endpoint",
      "call.phoenix_endpoint",
      nil,
      0
    )
  end
end
