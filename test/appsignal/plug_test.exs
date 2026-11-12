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

        get "/ignored" do
          Appsignal.Tracer.ignore()
          send_resp(var!(conn), 200, "Ignored!")
        end

        get "/leak" do
          Appsignal.Tracer.create_span("leaked", Appsignal.Tracer.current_span())
          send_resp(var!(conn), 200, "Leaked!")
        end

        get "/work_after_response" do
          conn = send_resp(var!(conn), 200, "Sent!")
          Process.sleep(200)
          conn
        end

        get "/task_exception" do
          Task.await(Task.async(fn -> raise "Exception in a task!" end))
          send_resp(var!(conn), 200, "Unreachable")
        end

        get "/custom_name" do
          conn = var!(conn)

          conn
          |> Appsignal.Plug.put_name("PlugRouter#custom_name")
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

  defmodule PlugRouter do
    use Plug.Router
    use Appsignal.Plug
    use Plug.ErrorHandler
    use AppsignalTest.PlugRoutes
  end

  defmodule UninstrumentedPlugRouter do
    use Plug.Router
    use Plug.ErrorHandler
    use AppsignalTest.PlugRoutes
  end

  defmodule Appsignal.PlugTest do
    use AppsignalTest.IntegrationCase
    import Plug.Test
    import Plug.Conn, only: [put_req_header: 3]

    setup context do
      if context[:deactivated], do: deactivate(), else: :ok
    end

    describe "handling a request, compared with the router without Appsignal.Plug" do
      test "responds as the router without Appsignal.Plug does" do
        %{conn: conn} = request(:get, "/")

        assert {conn.status, conn.resp_body, conn.resp_headers} ==
                 respond(UninstrumentedPlugRouter, :get, "/")
      end

      test "runs the router's own call/2" do
        assert %{conn: %Plug.Conn{state: :sent, assigns: %{overridden?: true}}} =
                 request(:get, "/")
      end

      test "reraises an error as the router without Appsignal.Plug does" do
        %{kind: kind, reason: reason} = request(:get, "/exception?id=4")

        assert {^kind, %Plug.Conn.WrapperError{reason: %RuntimeError{}}} =
                 raised(UninstrumentedPlugRouter, :get, "/exception?id=4")

        assert %Plug.Conn.WrapperError{reason: %RuntimeError{message: "Exception!"}} = reason
      end

      test "reraises an error with a status below 500" do
        assert %{reason: %Plug.Conn.WrapperError{reason: %Plug.BadRequestError{}}} =
                 request(:get, "/bad_request")
      end

      test "marks the conn as instrumented" do
        assert %{conn: %Plug.Conn{private: %{appsignal_plug_instrumented: true}}} =
                 request(:get, "/")
      end

      test "sends the response for a request with nil request headers" do
        conn = %{conn(:get, "/") | req_headers: nil}
        assert %Plug.Conn{state: :sent} = PlugRouter.call(conn, [])
      end

      test "sends the response when Appsignal.Plug is used twice" do
        ExUnit.CaptureLog.capture_log(fn ->
          send(self(), PlugRouter.call(already_wrapped_conn(), []))
        end)

        assert_received %Plug.Conn{state: :sent, status: 200}
      end

      test "logs that Appsignal.Plug is used twice" do
        log = ExUnit.CaptureLog.capture_log(fn -> PlugRouter.call(already_wrapped_conn(), []) end)

        assert log =~
                 "Appsignal.Plug was included twice, disabling Appsignal.Plug. Please only `use Appsignal.Plug` once."
      end
    end

    describe "the span recorded for a request" do
      test "is a root span named after the route" do
        request(:get, "/")

        assert [%{"parent_span_id" => ""} = span] = spans()
        assert span["name"] == "GET /"
        assert span["namespace"] == "http_request"
        assert category(span) == "call.plug"
        assert span["error"] == nil
      end

      test "has the request's environment" do
        request(:get, "/")

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

      test "is named after the route, not the path" do
        request(:get, "/users/4")
        assert [%{"name" => "GET /users/:id"}] = spans()
      end

      test "is named with Appsignal.Plug.put_name/2" do
        request(:get, "/custom_name")
        assert [%{"name" => "PlugRouter#custom_name"}] = spans()
      end

      test "is named after the Phoenix controller and action in the conn" do
        request(:get, "/phoenix_action")
        assert [%{"name" => "PlugRouter#phoenix_action"}] = spans()
      end

      test "has the query parameters as params" do
        request(:get, "/?id=4")
        assert [%{"sample_data" => %{"params" => %{"id" => "4"}}}] = spans()
      end

      test "has the parameters passed as the request's params" do
        request(:get, "/", %{id: "4"})
        assert [%{"sample_data" => %{"params" => %{"id" => "4"}}}] = spans()
      end

      test "has a span instrumented inside the request as its child" do
        %{conn: conn} = request(:get, "/instrumentation")
        assert %Plug.Conn{state: :sent, status: 200} = conn

        assert [root, child] = spans()
        assert root["name"] == "GET /instrumentation"
        assert child["name"] == "query.posts"
        assert child["parent_span_id"] == root["span_id"]
      end

      test "has the error when the request raises" do
        request(:get, "/exception?id=4")

        assert [span] = spans()
        assert span["name"] == "GET /exception"

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Exception!"} =
                 span["error"]

        assert span["sample_data"]["params"] == %{"id" => "4"}
        assert span["sample_data"]["environment"]["status"] == 500
      end

      test "has an Erlang error as its Elixir exception" do
        %{kind: :error, reason: %Plug.Conn.WrapperError{reason: :badarg}} =
          request(:get, "/badarg")

        assert [%{"error" => %{"name" => "ArgumentError"}}] = spans()
      end

      # Pins current behaviour, not intended behaviour: an exit or a throw leaves
      # the request's span without a name. See
      # https://github.com/appsignal/appsignal-elixir/issues/1086.
      test "has an exit as its error, without the request's name" do
        %{kind: :exit, reason: :exited} = request(:get, "/exit")

        assert [%{"error" => %{"name" => ":exit", "message" => "** (exit) :exited"}} = span] =
                 spans()

        assert span["name"] == ""
      end

      # Pins current behaviour, not intended behaviour: an exit or a throw leaves
      # the request's span without a name. See
      # https://github.com/appsignal/appsignal-elixir/issues/1086.
      test "has a throw as its error, without the request's name" do
        %{kind: :throw, reason: :thrown} = request(:get, "/throw")

        assert [%{"error" => %{"name" => ":throw", "message" => "** (throw) :thrown"}} = span] =
                 spans()

        assert span["name"] == ""
      end

      test "has no error for a status below 500" do
        request(:get, "/bad_request")
        assert [%{"error" => nil}] = spans()
      end

      # Pins current behaviour, not intended behaviour: the request's span is
      # left without its name and data. See
      # https://github.com/appsignal/appsignal-elixir/issues/1087.
      test "has no name or data for a status below 500" do
        request(:get, "/bad_request")

        assert [span] = spans()
        assert span["name"] == ""
        assert category(span) == nil
        refute Map.has_key?(span["sample_data"], "environment")
      end

      # Pins current behaviour, not intended behaviour: a request that calls
      # Tracer.ignore/0 is still reported. See
      # https://github.com/appsignal/appsignal-elixir/issues/1089.
      test "is still recorded for a request that calls Tracer.ignore/0" do
        %{conn: %Plug.Conn{status: 200}} = request(:get, "/ignored")
        assert [%{"name" => "GET /ignored", "closed" => true}] = spans()
      end

      test "is recorded for a request with nil request headers" do
        PlugRouter.call(%{conn(:get, "/") | req_headers: nil}, [])
        assert [_span] = spans()
      end
    end

    describe "the rest of the process's trace" do
      test "is ignored after the request raises" do
        request(:get, "/exception")
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end

      test "is ignored after an error with a status below 500" do
        request(:get, "/bad_request")
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end
    end

    describe "requests that record no span" do
      @tag :deactivated
      test "when AppSignal is not active" do
        assert %{kind: :error, reason: %Plug.Conn.WrapperError{reason: %RuntimeError{}}} =
                 request(:get, "/exception")

        assert spans() == []
      end

      test "when Appsignal.Plug is used twice" do
        ExUnit.CaptureLog.capture_log(fn -> PlugRouter.call(already_wrapped_conn(), []) end)
        assert spans() == []
      end
    end

    for server <- [:bandit, :plug_cowboy], Appsignal.Dependencies.present?(server) do
      describe "requests served by #{server}" do
        setup do
          [port: start_server(unquote(server))]
        end

        test "responds to each request", %{port: port} do
          assert {200, "Welcome"} = http_get(port, "/")
          assert {200, "User!"} = http_get(port, "/users/4")
          await_spans()
        end

        test "records each request on its own span", %{port: port} do
          http_get(port, "/")
          http_get(port, "/users/4")

          assert [%{"name" => "GET /"} = root, %{"name" => "GET /users/:id"}] = await_spans()
          assert root["sample_data"]["environment"]["host"] == "localhost"
        end

        test "responds to an error with the error handler's response", %{port: port} do
          assert {500, body} = http_get(port, "/exception")
          assert body =~ "Exception!"
          await_spans(&match?([%{"closed" => true}], &1))
        end

        test "records the error on the request's span", %{port: port} do
          http_get(port, "/exception")

          assert [%{"name" => "GET /exception", "error" => %{"name" => "RuntimeError"}}] =
                   await_spans(&match?([%{"closed" => true}], &1))
        end

        if server == :plug_cowboy do
          @tag leaves_spans_open: "the request's span, as its process is killed"
        end

        test "responds with an error to a request whose awaited task raises", %{port: port} do
          assert {500, _body} = http_get(port, "/task_exception")
          assert_task_exception_span(unquote(server))
        end

        if server == :plug_cowboy do
          @tag leaves_spans_open: "the request's span, as its process is killed"
        end

        test "records a request whose client disconnects after the response", %{port: port} do
          assert [200] =
                   Task.await(
                     Task.async(fn ->
                       AppsignalTest.KeepAliveClient.get(port, ["/work_after_response"])
                     end)
                   )

          assert_after_disconnect_span(unquote(server))
        end

        test "records a request after an ignored one on the same connection", %{port: port} do
          assert [200, 200] = AppsignalTest.KeepAliveClient.get(port, ["/ignored", "/"])
          assert_after_ignored_spans(unquote(server))
        end

        @tag leaves_spans_open: "the span the first request leaves open"
        test "records a request after one that leaves a span open on the same connection", %{
          port: port
        } do
          assert [200, 200] = AppsignalTest.KeepAliveClient.get(port, ["/leak", "/"])

          [leaking, leaked, next] =
            await_spans(&match?([%{"closed" => true}, _, %{"closed" => true}], &1))

          assert leaked["parent_span_id"] == leaking["span_id"]
          refute leaked["closed"]
          assert_after_leak_span(unquote(server), leaked, next)
        end
      end
    end

    # Pins current behaviour, not intended behaviour: when a task the request
    # awaits raises, Bandit records the exit on a span without the request's
    # name, and Cowboy records nothing. See
    # https://github.com/appsignal/appsignal-elixir/issues/1086 and
    # https://github.com/appsignal/appsignal-elixir/issues/1088.
    defp assert_task_exception_span(:bandit) do
      assert [span] = await_spans(&match?([%{"closed" => true}], &1))
      assert span["name"] == ""
      assert span["error"]["name"] == ":exit"
      assert span["error"]["message"] =~ "Exception in a task!"
    end

    defp assert_task_exception_span(:plug_cowboy) do
      assert [span] = await_spans(&match?([_], &1))
      refute span["closed"]
      assert span["error"] == nil
    end

    # Pins current behaviour, not intended behaviour: Cowboy stops the request's
    # process when its client disconnects, so its span is never closed. See
    # https://github.com/appsignal/appsignal-elixir/issues/1088.
    defp assert_after_disconnect_span(:bandit) do
      assert [%{"name" => "GET /work_after_response"}] =
               await_spans(&match?([%{"closed" => true}], &1))
    end

    defp assert_after_disconnect_span(:plug_cowboy) do
      Process.sleep(400)
      assert [%{"name" => "", "closed" => false}] = spans()
    end

    # Pins current behaviour, not intended behaviour: on Bandit, which serves a
    # connection's requests from one process, Tracer.ignore/0 and a span left
    # open carry over to the next request. See
    # https://github.com/appsignal/appsignal-elixir/issues/1089.
    defp assert_after_ignored_spans(:bandit) do
      assert [%{"name" => "GET /ignored"}] = await_spans(&match?([%{"closed" => true}], &1))
    end

    defp assert_after_ignored_spans(:plug_cowboy) do
      assert [%{"name" => "GET /ignored"}, %{"name" => "GET /"}] =
               await_spans(&match?([%{"closed" => true}, %{"closed" => true}], &1))
    end

    defp assert_after_leak_span(:bandit, leaked, next) do
      assert next["parent_span_id"] == leaked["span_id"]
    end

    defp assert_after_leak_span(:plug_cowboy, _leaked, next) do
      assert next["parent_span_id"] == ""
    end

    defp start_server(:bandit) do
      server = start_supervised!({Bandit, plug: PlugRouter, port: 0, startup_log: false})
      {:ok, {_address, port}} = ThousandIsland.listener_info(server)
      port
    end

    defp start_server(:plug_cowboy) do
      start_supervised!(
        {Plug.Cowboy, scheme: :http, plug: PlugRouter, options: [port: 0, ref: __MODULE__.Cowboy]}
      )

      :ranch.get_port(__MODULE__.Cowboy)
    end

    defp request(method, path, params_or_body \\ nil) do
      conn =
        method
        |> conn(path, params_or_body)
        |> put_req_header("accept", "text/html")

      try do
        %{conn: PlugRouter.call(conn, [])}
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

    defp deactivate do
      config = Application.get_env(:appsignal, :config)
      Application.put_env(:appsignal, :config, %{config | active: false})
      on_exit(fn -> Application.put_env(:appsignal, :config, config) end)
    end

    defp already_wrapped_conn do
      :get
      |> conn("/")
      |> Plug.Conn.put_private(:appsignal_plug_instrumented, true)
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
