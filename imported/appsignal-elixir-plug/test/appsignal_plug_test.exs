defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/exception" do
    raise "Exception!"

    send_resp(conn, 200, "Exception!")
  end

  get "/bad_request" do
    raise %Plug.BadRequestError{}

    send_resp(conn, 200, "Bad request!")
  end

  # NOTE: This test module includes an error handler to make sure AppSignal's
  # error handling keeps working even when custom error handlers are defined by
  # the host application.
  def handle_errors(conn, %{reason: reason}) do
    send_resp(conn, 500, inspect(reason))
  end
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  use Plug.Test
  alias Appsignal.{Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()
    :ok
  end

  describe "GET /" do
    setup do
      get("/")

      :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"web"}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET /"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /?id=4" do
    setup do
      get("/", %{id: "4"})

      :ok
    end

    test "sets the span's parameters" do
      assert {:ok, [{%Span{}, "params", %{"id" => "4"}}]} = Test.Span.get(:set_sample_data)
    end
  end

  describe "GET /?id=4, with unfetched parameters" do
    setup do
      get("/?id=4")

      :ok
    end

    test "sets the span's parameters" do
      assert {:ok, [{%Span{}, "params", %{"id" => "4"}}]} = Test.Span.get(:set_sample_data)
    end
  end

  describe "GET /exception?id=4" do
    setup do
      get("/exception", %{id: "4"})
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"web"}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET /exception"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's parameters" do
      assert {:ok, [{%Span{}, "params", %{"id" => "4"}}]} = Test.Span.get(:set_sample_data)
    end

    test "reraises the error", %{reason: reason} do
      assert %RuntimeError{} = reason
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, ^reason, ^stack}]} = Test.Span.get(:add_error)
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
      assert {:ok, [{%Span{}, "params", %{"id" => "4"}}]} = Test.Span.get(:set_sample_data)
    end
  end

  describe "GET /exception, when disabled" do
    setup :disable_appsignal

    setup do
      get("/exception")
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"web"}]}
    end

    test "adds the name to a nil-span" do
      assert {:ok, [{nil, "GET /exception"}]} = Test.Span.get(:set_name)
    end

    test "reraises the error", %{reason: reason} do
      assert %RuntimeError{} = reason
    end

    test "adds the error to a nil-span", %{stack: stack} do
      assert {:ok, [{nil, %RuntimeError{message: "Exception!"}, ^stack}]} =
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

  describe ".set_name/2" do
    setup do
      [span: Span.create_root("set_name", self())]
    end

    test "sets the span's name", %{span: span} do
      assert Appsignal.Plug.set_name(span, %Plug.Conn{
               method: "GET",
               private: %{plug_route: {"/", fn -> :ok end}}
             }) == span

      assert {:ok, [{^span, "GET /"}]} = Test.Span.get(:set_name)
    end

    test "ignores Phoenix conns", %{span: span} do
      assert Appsignal.Plug.set_name(span, %Plug.Conn{
               method: "GET",
               private: %{phoenix_endpoint: AppsignalPhoenixExampleWeb.Endpoint}
             }) == span

      assert Test.Span.get(:set_name) == :error
    end
  end

  defp get(path, params_or_body \\ nil) do
    [conn: PlugWithAppsignal.call(conn(:get, path, params_or_body), [])]
  rescue
    wrapper_error in Plug.Conn.WrapperError ->
      [
        conn: wrapper_error.conn,
        reason: wrapper_error.reason,
        stack: __STACKTRACE__
      ]
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end
end
