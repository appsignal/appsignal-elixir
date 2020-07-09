defmodule Appsignal.Phoenix.LiveView do
  defdelegate instrument(module, name, socket, fun), to: Appsignal.Phoenix.Channel
  defdelegate instrument(module, name, params, socket, fun), to: Appsignal.Phoenix.Channel

  def live_view_action(module, name, socket, function) do
    instrument(module, name, socket, function)
  end
end
