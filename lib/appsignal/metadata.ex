defprotocol Appsignal.Metadata do
  @fallback_to_any true
  @spec metadata(t) :: map()
  def metadata(value)

  @fallback_to_any true
  @spec name(t) :: nil | binary()
  def name(value)

  @fallback_to_any true
  @spec category(t) :: nil | binary()
  def category(value)

  @fallback_to_any true
  @spec params(t) :: map()
  def params(value)

  @fallback_to_any true
  @spec session(t) :: map()
  def session(value)
end

# Plug and Phoenix are not dependencies of this package, so their structs are
# matched here rather than given implementations of their own, which would
# have to name structs that do not exist when this package is compiled.
defimpl Appsignal.Metadata, for: Any do
  alias Appsignal.Phoenix.Metadata, as: PhoenixMetadata
  alias Appsignal.Plug.Metadata, as: PlugMetadata

  def metadata(%{__struct__: Plug.Conn} = conn), do: PlugMetadata.metadata(conn)
  def metadata(%{__struct__: Phoenix.Socket} = socket), do: PhoenixMetadata.socket(socket)

  def metadata(%{__struct__: Phoenix.LiveView.Socket} = socket),
    do: PhoenixMetadata.live_view_socket(socket)

  def metadata(_) do
    %{}
  end

  def name(%{__struct__: Plug.Conn} = conn), do: PlugMetadata.name(conn)

  def name(_) do
    nil
  end

  def category(%{__struct__: Plug.Conn} = conn), do: PlugMetadata.category(conn)

  def category(_) do
    nil
  end

  def params(%{__struct__: Plug.Conn} = conn), do: PlugMetadata.params(conn)

  def params(_) do
    %{}
  end

  def session(%{__struct__: Plug.Conn} = conn), do: PlugMetadata.session(conn)

  def session(_) do
    %{}
  end
end
