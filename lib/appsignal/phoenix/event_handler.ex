defmodule Appsignal.Phoenix.EventHandler do
  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  def handle_event([:phoenix, :endpoint, :start], _measurements, _metadata, _config) do
    @transaction.start_event()
  end
end
