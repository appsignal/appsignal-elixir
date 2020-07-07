defimpl Appsignal.Metadata, for: Phoenix.Socket do
  def metadata(%Phoenix.Socket{
        id: id,
        channel: channel,
        endpoint: endpoint,
        handler: handler,
        ref: ref,
        topic: topic,
        transport: transport
      }) do
    %{
      "channel" => channel,
      "endpoint" => endpoint,
      "handler" => handler,
      "id" => id,
      "ref" => ref,
      "topic" => topic,
      "transport" => transport
    }
  end
end

defimpl Appsignal.Metadata, for: Phoenix.LiveView.Socket do
  def metadata(%Phoenix.LiveView.Socket{
        id: id,
        root_view: root_view,
        view: view,
        endpoint: endpoint,
        router: router
      }) do
    %{
      "id" => id,
      "root_view" => root_view,
      "view" => view,
      "endpoint" => endpoint,
      "router" => router
    }
  end
end
