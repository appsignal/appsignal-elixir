defimpl Appsignal.Metadata, for: Plug.Conn do
  def metadata(%Plug.Conn{
        host: host,
        method: method,
        request_path: request_path,
        port: port
      }) do
    %{
      "host" => host,
      "method" => method,
      "request_path" => request_path,
      "port" => port
    }
  end
end
