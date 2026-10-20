if Appsignal.Dependencies.present?(:plug_cowboy) do
  defmodule AppsignalTest.HTTPServer do
    @moduledoc """
    An HTTP server on a free local port, for tests that send real requests
    through an HTTP client. It keeps every request it receives, so tests can
    assert on what reached it.

    A request to a path ending in `/status/<code>` is answered with that status
    code, any other request with 200. The body is always `"OK"`.
    """

    use Supervisor

    defmodule Router do
      @moduledoc false
      @behaviour Plug

      import Plug.Conn

      @impl true
      def init(opts), do: opts

      @impl true
      def call(conn, _opts) do
        {:ok, body, conn} = read_body(conn)

        request = %{
          method: conn.method,
          path: path(conn),
          headers: Map.new(conn.req_headers),
          body: body
        }

        Agent.update(AppsignalTest.HTTPServer.Requests, &[request | &1])
        send_resp(conn, status(Enum.take(conn.path_info, -2)), "OK")
      end

      defp path(%{request_path: path, query_string: ""}), do: path
      defp path(%{request_path: path, query_string: query}), do: path <> "?" <> query

      defp status(["status", code]), do: String.to_integer(code)
      defp status(_path_info), do: 200
    end

    def start_link(_opts \\ []) do
      Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
    end

    @doc "The URL of `path` on the running server."
    def url(path \\ "/") do
      "http://localhost:#{:ranch.get_port(__MODULE__.HTTP)}#{path}"
    end

    @doc """
    The `scheme://host:port` of `url`, which HTTP client integrations name their
    spans after.
    """
    def origin(url) do
      url |> URI.parse() |> Map.merge(%{path: nil, query: nil, userinfo: nil}) |> URI.to_string()
    end

    @doc """
    The requests received so far, oldest first, as maps with `:method`,
    `:path`, `:headers` (lowercased names) and `:body`.
    """
    def requests do
      Agent.get(__MODULE__.Requests, &Enum.reverse/1)
    end

    @doc "A URL on a local port that refuses connections."
    def refused_url(path \\ "/") do
      {:ok, socket} = :gen_tcp.listen(0, ip: {127, 0, 0, 1})
      {:ok, port} = :inet.port(socket)
      :ok = :gen_tcp.close(socket)
      "http://localhost:#{port}#{path}"
    end

    @impl true
    def init(nil) do
      children = [
        %{
          id: :requests,
          start: {Agent, :start_link, [fn -> [] end, [name: __MODULE__.Requests]]}
        },
        {Plug.Cowboy,
         scheme: :http, plug: Router, options: [ip: {127, 0, 0, 1}, port: 0, ref: __MODULE__.HTTP]}
      ]

      Supervisor.init(children, strategy: :one_for_all)
    end
  end
end
