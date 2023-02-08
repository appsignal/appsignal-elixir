defimpl Appsignal.Metadata, for: Phoenix.Socket do
  def metadata(%Phoenix.Socket{} = socket) do
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

  defdelegate name(socket), to: Appsignal.Metadata.Any
  defdelegate category(socket), to: Appsignal.Metadata.Any
  defdelegate params(socket), to: Appsignal.Metadata.Any
  defdelegate session(socket), to: Appsignal.Metadata.Any
end

if Code.ensure_loaded?(Phoenix.LiveView) do
  defimpl Appsignal.Metadata, for: Phoenix.LiveView.Socket do
    def metadata(%Phoenix.LiveView.Socket{} = socket) do
      %{
        "id" => Map.get(socket, :id),
        "root_view" => root_view(socket),
        "view" => Map.get(socket, :view),
        "endpoint" => Map.get(socket, :endpoint),
        "router" => Map.get(socket, :router)
      }
    end

    defp root_view(socket) do
      socket |> Map.get(:private, %{}) |> Map.get(:root_view) || Map.get(socket, :root_view)
    end

    defdelegate name(socket), to: Appsignal.Metadata.Any
    defdelegate category(socket), to: Appsignal.Metadata.Any
    defdelegate params(socket), to: Appsignal.Metadata.Any
    defdelegate session(socket), to: Appsignal.Metadata.Any
  end
end
