defmodule Appsignal.Phoenix.Metadata do
  @moduledoc false

  def socket(%{__struct__: Phoenix.Socket} = socket) do
    %{
      "channel" => Map.get(socket, :channel),
      "endpoint" => Map.get(socket, :endpoint),
      "handler" => Map.get(socket, :handler),
      "id" => Map.get(socket, :id),
      "ref" => Map.get(socket, :ref),
      "topic" => Map.get(socket, :topic),
      "transport" => Map.get(socket, :transport)
    }
  end

  def live_view_socket(%{__struct__: Phoenix.LiveView.Socket} = socket) do
    %{
      "id" => Map.get(socket, :id),
      "root_view" => root_view(socket),
      "view" => Map.get(socket, :view),
      "endpoint" => Map.get(socket, :endpoint),
      "router" => Map.get(socket, :router)
    }
  end

  defp root_view(socket) do
    socket |> Map.get(:private, %{}) |> Map.get(:root_view)
  end
end
