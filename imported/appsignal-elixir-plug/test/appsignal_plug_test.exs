defmodule RequestId do
  def init(_opts) do
    :ok
  end

  def call(conn, _opts) do
    Plug.Conn.put_resp_header(conn, "x-request-id", "request_id")
  end
end

defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug
  use Plug.ErrorHandler

  plug(RequestId)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/users/:id" do
    send_resp(conn, 200, "User!")
  end

  get "/instrumentation" do
    Appsignal.instrument("query.posts", fn ->
      send_resp(conn, 200, "Welcome")
    end)
  end

  get "/exception" do
    raise "Exception!"

    send_resp(conn, 200, "Exception!")
  end

  get "/bad_request" do
    raise %Plug.BadRequestError{}

    send_resp(conn, 200, "Bad request!")
  end

  get "/badarg" do
    _ = String.to_integer("one")

    send_resp(conn, 200, "Bad request!")
  end

  get "/exit" do
    exit(:exited)

    send_resp(conn, 200, "Exit!")
  end

  get "/throw" do
    throw(:thrown)

    send_resp(conn, 200, "Exit!")
  end

  get "/custom_name" do
    conn
    |> Appsignal.Plug.put_name("PlugWithAppsignal#custom_name")
    |> send_resp(200, "Custom name!")
  end

  get "/phoenix_action" do
    conn
    |> Plug.Conn.put_private(:phoenix_controller, __MODULE__)
    |> Plug.Conn.put_private(:phoenix_action, "phoenix_action")
  end

  # NOTE: This test module includes an call/2 override and an error handler to
  # make sure AppSignal does not interfere with either of these, if defined by
  # the host application.

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:overridden?, true)
    |> super(opts)
  end

  def handle_errors(conn, %{reason: reason}) do
    send_resp(conn, 500, inspect(reason))
  end
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  use Plug.Test
  alias Appsignal.{Span, Test}
  doctest Appsignal.Plug

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()
    :ok
  end

  describe "GET /" do
    setup do
      get("/")
    end

    test "returns the conn", %{conn: conn} do
      assert %Plug.Conn{state: :sent} = conn
    end

    test "passes through the overridden call", %{conn: conn} do
      assert %Plug.Conn{assigns: %{overridden?: true}} = conn
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "set's the span's namespace" do
      assert {:ok, [{%Span{}, "http_request"}]} = Test.Span.get(:set_namespace)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET /"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, [{%Span{}, "appsignal:category", "call.plug"}]} = Test.Span.get(:set_attribute)
    end

    test "sets the span's sample data" do
      assert sample_data("environment", %{
               "host" => "www.example.com",
               "method" => "GET",
               "port" => 80,
               "request_path" => "/",
               "status" => 200,
               "request_id" => "request_id",
               "req_headers.accept" => "text/html"
             })
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "sets the :appsignal_plug_instrumented flag", %{conn: conn} do
      assert %Plug.Conn{private: %{appsignal_plug_instrumented: true}} = conn
    end
  end

  describe "GET /users/:id" do
    setup do
      get("/users/4")
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET /users/:id"}]} = Test.Span.get(:set_name)
    end
  end

  describe "GET /?id=4" do
    setup do
      get("/", %{id: "4"})

      :ok
    end

    test "sets the span's parameters" do
      assert sample_data("params", %{"id" => "4"})
    end
  end

  describe "GET /?id=4, with unfetched parameters" do
    setup do
      get("/?id=4")

      :ok
    end

    test "sets the span's parameters" do
      assert sample_data("params", %{"id" => "4"})
    end
  end

  describe "GET /instrumentation" do
    setup do
      get("/instrumentation")
    end

    test "returns the conn", %{conn: conn} do
      assert %Plug.Conn{state: :sent} = conn
    end

    test "passes through the overridden call", %{conn: conn} do
      assert %Plug.Conn{assigns: %{overridden?: true}} = conn
    end

    test "creates a root span and a child span" do
      assert {:ok, [{_, %Span{}}, {_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the root span's name" do
      assert {:ok, [{%Span{}, "GET /instrumentation"} | _]} = Test.Span.get(:set_name)
    end

    test "sets the span's sample data" do
      assert sample_data("environment", %{
               "host" => "www.example.com",
               "method" => "GET",
               "port" => 80,
               "request_path" => "/instrumentation",
               "status" => 200,
               "request_id" => "request_id",
               "req_headers.accept" => "text/html"
             })
    end

    test "closes both spans" do
      assert {:ok, [{%Span{}}, {%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /exception?id=4" do
    setup do
      get("/exception", %{id: "4"})
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET /exception"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's parameters" do
      assert sample_data("params", %{"id" => "4"})
    end

    test "sets the span's sample data" do
      assert sample_data("environment", %{
               "host" => "www.example.com",
               "method" => "GET",
               "port" => 80,
               "request_path" => "/exception",
               "status" => 500,
               "request_id" => "request_id",
               "req_headers.accept" => "text/html"
             })
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :error
      assert %RuntimeError{} = reason
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "ignores the process in the registry" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "GET /exception?id=4, with unfetched parameters" do
    setup do
      get("/exception?id=4")

      :ok
    end

    test "sets the span's parameters" do
      assert sample_data("params", %{"id" => "4"})
    end
  end

  describe "GET /badarg" do
    setup do
      get("/badarg")
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :error
      assert :badarg = reason
    end

    test "adds the error to the span", %{stack: stack} do
      assert {:ok, [{%Span{}, :error, :badarg, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe "GET /exit" do
    setup do
      get("/exit")
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :exit
      assert :exited = reason
    end

    test "adds the error to the span", %{stack: stack} do
      assert {:ok, [{%Span{}, :exit, :exited, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe "GET /throw" do
    setup do
      get("/throw")
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :throw
      assert :thrown = reason
    end

    test "adds the error to the span", %{stack: stack} do
      assert {:ok, [{%Span{}, :throw, :thrown, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe "GET /exception, when disabled" do
    setup :disable_appsignal

    setup do
      get("/exception")
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "adds the name to a nil-span" do
      assert {:ok, [{nil, "GET /exception"}]} = Test.Span.get(:set_name)
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :error
      assert %RuntimeError{} = reason
    end

    test "adds the error to a nil-span", %{stack: stack} do
      assert {:ok, [{nil, :error, %RuntimeError{message: "Exception!"}, ^stack}]} =
               Test.Span.get(:add_error)
    end

    test "closes the nil-span" do
      assert {:ok, [{nil}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /bad_request" do
    setup do
      get("/bad_request")
    end

    test "reraises the error", %{reason: reason} do
      assert %Plug.BadRequestError{} = reason
    end

    test "does not add the error to the span" do
      assert :error = Test.Span.get(:add_error)
    end

    test "ignores the process in the registry" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "GET /custom_name" do
    setup do
      get("/custom_name")
    end

    test "does not overwrite the custom name" do
      assert {:ok, [{%Span{}, "PlugWithAppsignal#custom_name"}]} = Test.Span.get(:set_name)
    end
  end

  describe "GET /phoenix_action" do
    setup do
      get("/phoenix_action")
    end

    test "extracts the controller and action name" do
      assert {:ok, [{%Span{}, "PlugWithAppsignal#phoenix_action"}]} = Test.Span.get(:set_name)
    end
  end

  describe "GET /, when plugging Appsignal.Plug twice" do
    setup do
      conn =
        :get
        |> conn("/", nil)
        |> Plug.Conn.put_private(:appsignal_plug_instrumented, true)

      [conn: conn]
    end

    test "prints a double-plugging error", %{conn: conn} do
      assert ExUnit.CaptureLog.capture_log(fn ->
               PlugWithAppsignal.call(conn, [])
             end) =~
               "Appsignal.Plug was included twice, disabling Appsignal.Plug. Please only `use Appsignal.Plug` once."
    end

    test "returns the conn", %{conn: conn} do
      conn = PlugWithAppsignal.call(conn, [])
      assert %Plug.Conn{state: :sent} = conn
    end
  end

  describe ".set_conn_data/2" do
    setup do
      [span: Span.create_root("set_conn_data", self())]
    end

    test "sets the span's name", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{
               method: "GET",
               private: %{plug_route: {"/", fn -> :ok end}}
             }) == span

      assert {:ok, [{^span, "GET /"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{}) == span

      assert {:ok, [{^span, "appsignal:category", "call.plug"}]} = Test.Span.get(:set_attribute)
    end

    test "sets the span's category, with a Phoenix conn", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{
               private: %{phoenix_endpoint: Appsignal.Endpoint}
             }) == span

      assert {:ok, [{^span, "appsignal:category", "call.phoenix"}]} =
               Test.Span.get(:set_attribute)
    end

    test "ignores Phoenix conns", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{
               method: "GET",
               private: %{phoenix_endpoint: AppsignalPhoenixExampleWeb.Endpoint}
             }) == span

      assert Test.Span.get(:set_name) == :error
    end

    test "sets the span's session data", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{
               method: "GET",
               private: %{
                 plug_route: {"/", fn -> :ok end},
                 plug_session: %{key: "value"},
                 plug_session_fetch: true
               }
             }) == span

      assert sample_data("session_data", %{key: "value"})
    end

    test "does not set unfetched session data", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{}) == span
      refute sample_data("session_data", %{key: "value"})
    end

    test "does not set session data when skip_session_data is set to true", %{span: span} do
      config = Application.get_env(:appsignal, :config)
      Application.put_env(:appsignal, :config, %{config | skip_session_data: true})

      try do
        Appsignal.Plug.set_conn_data(span, %Plug.Conn{
          method: "GET",
          private: %{
            plug_route: {"/", fn -> :ok end},
            plug_session: %{key: "value"},
            plug_session_fetch: true
          }
        })
      after
        Application.put_env(:appsignal, :config, config)
      end

      refute sample_data("session_data", %{key: "value"})
    end
  end

  defp get(path, params_or_body \\ nil) do
    conn =
      :get
      |> conn(path, params_or_body)
      |> put_req_header("accept", "text/html")

    try do
      [conn: PlugWithAppsignal.call(conn, [])]
    catch
      kind, reason ->
        case reason do
          %Plug.Conn.WrapperError{conn: conn, reason: reason} ->
            [conn: conn, kind: kind, reason: reason, stack: __STACKTRACE__]

          _ ->
            [conn: conn, kind: kind, reason: reason, stack: __STACKTRACE__]
        end
    end
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end

  defp sample_data(asserted_key, asserted_data) do
    {:ok, sample_data} = Test.Span.get(:set_sample_data)

    Enum.any?(sample_data, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end
end
