defimpl Appsignal.Metadata, for: Phoenix.Socket do
  def metadata(%Phoenix.Socket{} = socket) do
    %{
      "channel" => socket[:channel],
      "endpoint" => socket[:endpoint],
      "handler" => socket[:handler],
      "id" => socket[:id],
      "ref" => socket[:ref],
      "topic" => socket[:topic],
      "transport" => socket[:transport]
    }
  end
end

if Code.ensure_loaded?(Phoenix.LiveView) do
  defimpl Appsignal.Metadata, for: Phoenix.LiveView.Socket do
    def metadata(%Phoenix.LiveView.Socket{} = socket) do
      %{
        "id" => socket[:id],
        "root_view" => socket[:root_view],
        "view" => socket[:view],
        "endpoint" => socket[:endpoint],
        "router" => socket[:router]
      }
    end
  end
end
