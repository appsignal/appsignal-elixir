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

  def name(%Plug.Conn{private: %{appsignal_name: appsignal_name}}) do
    appsignal_name
  end

  def name(%Plug.Conn{private: %{phoenix_action: action, phoenix_controller: controller}}) do
    "#{Appsignal.Utils.module_name(controller)}##{action}"
  end

  def name(%Plug.Conn{method: method, private: %{plug_route: {path, _fun}}}) do
    "#{method} #{path}"
  end

  def name(_conn) do
    nil
  end

  def category(%Plug.Conn{private: %{phoenix_endpoint: _}}) do
    "call.phoenix"
  end

  def category(_conn) do
    "call.plug"
  end

  def params(conn) do
    %Plug.Conn{params: params} = Plug.Conn.fetch_query_params(conn)
    params
  end

  def session(%Plug.Conn{private: %{plug_session: session}}) do
    session
  end

  def session(_conn) do
    %{}
  end

  defp headers(req_headers) do
    headers(req_headers, %{})
  end

  defp headers([{key, value} | tail], acc) do
    acc =
      case key in Appsignal.Config.request_headers() do
        true -> Map.put(acc, "req_headers.#{key}", value)
        false -> acc
      end

    headers(tail, acc)
  end

  defp headers(_, acc) do
    acc
  end
end
