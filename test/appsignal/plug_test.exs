if Appsignal.Dependencies.present?(:plug) do
  defmodule AppsignalTest.PlugRoutes do
    @moduledoc false

    # The routes both test routers share, so the one with `Appsignal.Plug`
    # can be compared with the one without.
    defmacro __using__(_opts) do
      quote do
        plug(AppsignalTest.PlugRoutes.RequestId)
        plug(:match)
        plug(:dispatch)

        get "/" do
          send_resp(var!(conn), 200, "Welcome")
        end

        get "/users/:id" do
          send_resp(var!(conn), 200, "User!")
        end

        get "/instrumentation" do
          Appsignal.instrument("query.posts", fn ->
            send_resp(var!(conn), 200, "Welcome")
          end)
        end

        get "/exception" do
          raise "Exception!"
        end

        get "/bad_request" do
          raise %Plug.BadRequestError{}
        end

        get "/badarg" do
          String.to_integer("one")
        end

        get "/exit" do
          exit(:exited)
        end

        get "/throw" do
          throw(:thrown)
        end

        get "/custom_name" do
          conn = var!(conn)

          conn
          |> Appsignal.Plug.put_name("PlugWithAppsignal#custom_name")
          |> send_resp(200, "Custom name!")
        end

        get "/phoenix_action" do
          conn = var!(conn)

          conn
          |> Plug.Conn.put_private(:phoenix_controller, __MODULE__)
          |> Plug.Conn.put_private(:phoenix_action, "phoenix_action")
          |> send_resp(200, "Phoenix action!")
        end

        # Applications override `call/2` and handle errors themselves. Both
        # have to keep working with `Appsignal.Plug` in place.
        def call(conn, opts) do
          conn
          |> Plug.Conn.assign(:overridden?, true)
          |> super(opts)
        end

        def handle_errors(conn, %{reason: reason}) do
          send_resp(conn, 500, inspect(reason))
        end
      end
    end

    defmodule RequestId do
      @moduledoc false
      def init(_opts), do: :ok
      def call(conn, _opts), do: Plug.Conn.put_resp_header(conn, "x-request-id", "request_id")
    end
  end

  defmodule PlugWithAppsignal do
    use Plug.Router
    use Appsignal.Plug
    use Plug.ErrorHandler
    use AppsignalTest.PlugRoutes
  end

  defmodule PlugWithoutAppsignal do
    use Plug.Router
    use Plug.ErrorHandler
    use AppsignalTest.PlugRoutes
  end

  defmodule Appsignal.PlugTest do
    use AppsignalTest.IntegrationCase
    import Plug.Test
    import Plug.Conn, only: [put_req_header: 3]

    describe "GET /" do
      setup do
        request(:get, "/")
      end

      test "responds as the router does without Appsignal.Plug", %{conn: conn} do
        assert {conn.status, conn.resp_body, conn.resp_headers} ==
                 respond(PlugWithoutAppsignal, :get, "/")

        assert %Plug.Conn{state: :sent, assigns: %{overridden?: true}} = conn
      end

      test "marks the conn as instrumented", %{conn: conn} do
        assert %Plug.Conn{private: %{appsignal_plug_instrumented: true}} = conn
      end

      test "records one closed root span for the request" do
        assert [%{"closed" => true, "parent_span_id" => ""} = span] = spans()
        assert span["name"] == "GET /"
        assert span["namespace"] == "http_request"
        assert category(span) == "call.plug"
        assert span["error"] == nil
      end

      test "records the request environment" do
        assert [%{"sample_data" => %{"environment" => environment}}] = spans()

        assert environment == %{
                 "host" => "www.example.com",
                 "method" => "GET",
                 "port" => 80,
                 "request_path" => "/",
                 "status" => 200,
                 "request_id" => "request_id",
                 "req_headers.accept" => "text/html"
               }
      end
    end

    test "names the span after the route, not the path" do
      request(:get, "/users/4")
      assert [%{"name" => "GET /users/:id"}] = spans()
    end

    test "records the query parameters" do
      request(:get, "/?id=4")
      assert [%{"sample_data" => %{"params" => %{"id" => "4"}}}] = spans()
    end

    test "records parameters passed as the request's params" do
      request(:get, "/", %{id: "4"})
      assert [%{"sample_data" => %{"params" => %{"id" => "4"}}}] = spans()
    end

    test "names the span with Appsignal.Plug.put_name/2" do
      request(:get, "/custom_name")
      assert [%{"name" => "PlugWithAppsignal#custom_name"}] = spans()
    end

    test "names the span after the Phoenix controller and action in the conn" do
      request(:get, "/phoenix_action")
      assert [%{"name" => "PlugWithAppsignal#phoenix_action"}] = spans()
    end

    test "records a span instrumented inside the request as its child" do
      %{conn: conn} = request(:get, "/instrumentation")
      assert %Plug.Conn{state: :sent, status: 200} = conn

      assert [root, child] = spans()
      assert root["name"] == "GET /instrumentation"
      assert child["name"] == "query.posts"
      assert child["parent_span_id"] == root["span_id"]
      assert root["closed"] and child["closed"]
    end

    describe "GET /exception?id=4" do
      setup do
        request(:get, "/exception?id=4")
      end

      test "reraises the error as the router does without Appsignal.Plug", %{
        kind: kind,
        reason: reason
      } do
        assert {^kind, %Plug.Conn.WrapperError{reason: %RuntimeError{}}} =
                 raised(PlugWithoutAppsignal, :get, "/exception?id=4")

        assert %Plug.Conn.WrapperError{reason: %RuntimeError{message: "Exception!"}} = reason
      end

      test "records the error on the request's span" do
        assert [%{"closed" => true} = span] = spans()
        assert span["name"] == "GET /exception"

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Exception!"} =
                 span["error"]

        assert span["sample_data"]["params"] == %{"id" => "4"}
        assert span["sample_data"]["environment"]["status"] == 500
      end

      test "ignores the rest of the process's trace" do
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end
    end

    test "records an Erlang error by its Elixir exception" do
      %{kind: :error, reason: %Plug.Conn.WrapperError{reason: :badarg}} =
        request(:get, "/badarg")

      assert [%{"error" => %{"name" => "ArgumentError"}}] = spans()
    end

    test "records an exit" do
      %{kind: :exit, reason: :exited} = request(:get, "/exit")
      assert [%{"error" => %{"name" => ":exit", "message" => "** (exit) :exited"}}] = spans()
    end

    test "records a throw" do
      %{kind: :throw, reason: :thrown} = request(:get, "/throw")
      assert [%{"error" => %{"name" => ":throw", "message" => "** (throw) :thrown"}}] = spans()
    end

    describe "GET /bad_request" do
      setup do
        request(:get, "/bad_request")
      end

      test "reraises the error", %{reason: reason} do
        assert %Plug.Conn.WrapperError{reason: %Plug.BadRequestError{}} = reason
      end

      test "does not record an error for a status below 500" do
        assert [%{"closed" => true, "error" => nil}] = spans()
      end

      test "ignores the rest of the process's trace" do
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end
    end

    describe "when AppSignal is not active" do
      setup :deactivate

      test "records no spans and reraises the error" do
        assert %{kind: :error, reason: %Plug.Conn.WrapperError{reason: %RuntimeError{}}} =
                 request(:get, "/exception")

        assert spans() == []
      end
    end

    describe "when Appsignal.Plug is used twice" do
      setup do
        conn =
          :get
          |> conn("/")
          |> Plug.Conn.put_private(:appsignal_plug_instrumented, true)

        [conn: conn]
      end

      test "logs that it is used twice and records no span", %{conn: conn} do
        log = ExUnit.CaptureLog.capture_log(fn -> PlugWithAppsignal.call(conn, []) end)

        assert log =~
                 "Appsignal.Plug was included twice, disabling Appsignal.Plug. Please only `use Appsignal.Plug` once."

        assert spans() == []
      end

      test "still sends the response", %{conn: conn} do
        ExUnit.CaptureLog.capture_log(fn ->
          send(self(), PlugWithAppsignal.call(conn, []))
        end)

        assert_received %Plug.Conn{state: :sent, status: 200}
      end
    end

    test "handles requests with nil request headers" do
      conn = %{conn(:get, "/") | req_headers: nil}
      assert %Plug.Conn{state: :sent} = PlugWithAppsignal.call(conn, [])
      assert [%{"closed" => true}] = spans()
    end

    if Appsignal.Dependencies.present?(:bandit) do
      describe "through a Bandit server" do
        setup do
          server =
            start_supervised!({Bandit, plug: PlugWithAppsignal, port: 0, startup_log: false})

          {:ok, {_address, port}} = ThousandIsland.listener_info(server)
          [port: port]
        end

        test "responds and records the request's span", %{port: port} do
          assert {200, "Welcome"} = http_get(port, "/")
          assert {200, "User!"} = http_get(port, "/users/4")

          assert [%{"name" => "GET /"} = root, %{"name" => "GET /users/:id"}] = await_spans()
          assert root["sample_data"]["environment"]["host"] == "localhost"
        end

        test "sends the error handler's response and records the error", %{port: port} do
          assert {500, body} = http_get(port, "/exception")
          assert body =~ "Exception!"

          assert [%{"name" => "GET /exception", "error" => %{"name" => "RuntimeError"}}] =
                   await_spans(&match?([%{"closed" => true}], &1))
        end
      end
    end

    defp request(method, path, params_or_body \\ nil) do
      conn =
        method
        |> conn(path, params_or_body)
        |> put_req_header("accept", "text/html")

      try do
        %{conn: PlugWithAppsignal.call(conn, [])}
      catch
        kind, reason -> %{conn: conn, kind: kind, reason: reason}
      end
    end

    defp respond(router, method, path) do
      conn =
        method
        |> conn(path)
        |> put_req_header("accept", "text/html")
        |> router.call([])

      {conn.status, conn.resp_body, conn.resp_headers}
    end

    defp raised(router, method, path) do
      router.call(conn(method, path), [])
      flunk("#{inspect(router)} did not raise")
    catch
      kind, reason -> {kind, reason}
    end

    defp http_get(port, path) do
      {:ok, _} = Application.ensure_all_started(:inets)

      {:ok, {{_, status, _}, _headers, body}} =
        :httpc.request(:get, {~c"http://localhost:#{port}#{path}", []}, [], [])

      {status, to_string(body)}
    end

    defp deactivate(_context) do
      config = Application.get_env(:appsignal, :config)
      Application.put_env(:appsignal, :config, %{config | active: false})
      on_exit(fn -> Application.put_env(:appsignal, :config, config) end)
    end
  end

  defmodule Appsignal.PlugDocTest do
    use ExUnit.Case, async: true
    doctest Appsignal.Plug
  end

  defmodule Appsignal.Plug.SetConnDataTest do
    use ExUnit.Case
    alias Appsignal.{Span, Test}

    @moduletag :skip_env_test_no_nif

    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      [span: Span.create_root("set_conn_data", self())]
    end

    test "sets the span's name from the route", %{span: span} do
      assert Appsignal.Plug.set_conn_data(span, %Plug.Conn{
               method: "GET",
               private: %{plug_route: {"/", fn -> :ok end}}
             }) == span

      assert %{"name" => "GET /"} = Span.to_map(span)
    end

    test "sets the category", %{span: span} do
      Appsignal.Plug.set_conn_data(span, %Plug.Conn{})
      assert %{"attributes" => %{"appsignal:category" => "call.plug"}} = Span.to_map(span)
    end

    test "sets the Phoenix category for a Phoenix conn", %{span: span} do
      Appsignal.Plug.set_conn_data(span, %Plug.Conn{
        private: %{phoenix_endpoint: Appsignal.Endpoint}
      })

      assert %{"attributes" => %{"appsignal:category" => "call.phoenix"}} = Span.to_map(span)
    end

    test "does not set params when send_params is false", %{span: span} do
      config = Application.get_env(:appsignal, :config)
      Application.put_env(:appsignal, :config, %{config | send_params: false})

      try do
        Appsignal.Plug.set_conn_data(span, %Plug.Conn{method: "GET", params: %{"id" => "4"}})
      after
        Application.put_env(:appsignal, :config, config)
      end

      %{"sample_data" => sample_data} = Span.to_map(span)
      refute Map.has_key?(sample_data, "params")
    end

    test "sets the session data", %{span: span} do
      Appsignal.Plug.set_conn_data(span, %Plug.Conn{
        method: "GET",
        private: %{
          plug_route: {"/", fn -> :ok end},
          plug_session: %{key: "value"},
          plug_session_fetch: :done
        }
      })

      assert %{"sample_data" => %{"session_data" => ~s({"key":"value"})}} = Span.to_map(span)
    end
  end
end
