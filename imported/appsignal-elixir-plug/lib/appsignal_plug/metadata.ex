defimpl Appsignal.Metadata, for: Plug.Conn do
  def metadata(
        %Plug.Conn{
          req_headers: req_headers,
          host: host,
          method: method,
          request_path: request_path,
          port: port,
          status: status
        } = conn
      ) do
    request_id =
      conn
      |> Plug.Conn.get_resp_header("x-request-id")
      |> List.first()

    Map.merge(
      %{
        "host" => host,
        "method" => method,
        "request_path" => request_path,
        "port" => port,
        "request_id" => request_id,
        "status" => status
      },
      headers(req_headers)
    )
  end

  defp headers(req_headers) do
    for {key, value} <- req_headers,
        key in Appsignal.Config.request_headers() do
      {"req_headers.#{key}", value}
    end
    |> Enum.into(%{})
  end
end
