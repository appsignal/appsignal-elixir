defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/exception" do
    raise "Exception!"

    send_resp(conn, 200, "Exception!")
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
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "GET /"}] = Test.Span.get!(:set_name)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
    end
  end

  describe "GET /?id=4" do
    setup do
      get("/", %{id: 4})

      :ok
    end

    test "sets the span's parameters" do
      assert [{%Span{}, "params", %{"id" => 4}}] = Test.Span.get!(:set_sample_data)
    end
  end

  describe "GET /exception" do
    setup do
      get("/exception", %{id: 4})
    end

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "GET /exception"}] = Test.Span.get!(:set_name)
    end

    test "sets the span's parameters" do
      assert [{%Span{}, "params", %{"id" => 4}}] = Test.Span.get!(:set_sample_data)
    end

    test "adds the error to the span", %{exception: exception, stacktrace: stack} do
      assert [{%Span{}, ^exception, ^stack}] = Test.Span.get!(:add_error)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
    end

    test "ignores the process in the registry" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "GET /exception, when disabled" do
    setup :disable_appsignal

    setup do
      get("/exception")
    end

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "adds the name to a nil-span" do
      assert [{nil, "GET /exception"}] = Test.Span.get!(:set_name)
    end

    test "adds the error to a nil-span", %{stacktrace: stack} do
      assert [{nil, %RuntimeError{message: "Exception!"}, ^stack}] = Test.Span.get!(:add_error)
    end

    test "closes the nil-span" do
      assert [{nil}] = Test.Tracer.get!(:close_span)
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

      assert [{^span, "GET /"}] = Test.Span.get!(:set_name)
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
        exception: wrapper_error.reason,
        stacktrace: System.stacktrace()
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
