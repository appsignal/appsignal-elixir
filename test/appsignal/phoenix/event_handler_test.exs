if Appsignal.Dependencies.present?(:phoenix) do
  defmodule Appsignal.Phoenix.EventHandlerTest do
    use AppsignalTest.IntegrationCase
    import Phoenix.ConnTest
    alias AppsignalTest.Phoenix.MountingEndpoint

    @endpoint AppsignalTest.Phoenix.Endpoint

    setup do
      start_supervised!({Phoenix.PubSub, name: AppsignalTest.Phoenix.PubSub})
      start_supervised!(@endpoint)
      :ok
    end

    describe "handling a request through Phoenix" do
      test "sends the action's response" do
        assert %Plug.Conn{status: 200, resp_body: "Welcome to Phoenix!"} =
                 get(build_conn(), "/?id=4")
      end

      test "renders the action's template" do
        assert get(build_conn(), "/show?name=Phoenix").resp_body =~ "Hello, Phoenix!"
      end

      test "streams a chunked response" do
        assert get(build_conn(), "/chunked").resp_body == "Hello, chunks!"
      end

      # Pins current behaviour, not intended behaviour: the router dispatch span
      # stays open after the request raises. See
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "raises the action's error" do
        assert_raise RuntimeError, "Exception!", fn -> get(build_conn(), "/exception?id=4") end
      end
    end

    describe "the root span recorded for a request" do
      test "is the endpoint span, in the http_request namespace" do
        get(build_conn(), "/?id=4")

        assert [root | _] = spans()
        assert root["parent_span_id"] == ""
        assert root["namespace"] == "http_request"
        assert category(root) == "call.phoenix_endpoint"
      end

      test "is named after the controller and action" do
        get(build_conn(), "/?id=4")
        assert [%{"name" => "AppsignalTest.Phoenix.PageController#index"}, _dispatch] = spans()
      end

      test "is named after the action for a route with parameters" do
        get(build_conn(), "/users/4")
        assert [%{"name" => "AppsignalTest.Phoenix.PageController#index"}, _dispatch] = spans()
      end

      test "is named after a decorated action" do
        get(build_conn(), "/decorated")

        assert [%{"name" => "AppsignalTest.Phoenix.PageController#decorated"} | _] = spans()
      end

      test "is named after the action of a Phoenix router the request is forwarded to" do
        assert %Plug.Conn{status: 200} = get(build_conn(), "/forwarded_to_phoenix")

        assert [%{"name" => "AppsignalTest.Phoenix.PageController#index"} | _] = spans()
      end

      test "is named after the route of a Plug router the request is forwarded to" do
        assert %Plug.Conn{resp_body: "Forwarded to Plug"} =
                 get(build_conn(), "/forwarded_to_plug")

        assert [%{"name" => "GET /"}, _dispatch] = spans()
      end

      test "is named after the route when a router pipeline halts the request" do
        assert %Plug.Conn{status: 401} = get(build_conn(), "/halted")

        assert [%{"name" => "GET /halted"} = root, _dispatch] = spans()
        assert root["sample_data"]["environment"]["status"] == 401
      end

      test "has no name or error when no route matches" do
        assert %Plug.Conn{status: 404} = get(build_conn(), "/missing")

        assert [root, _render] = spans()
        assert root["name"] == ""
        assert root["error"] == nil
      end

      test "has the request's parameters, environment and metadata" do
        get(build_conn(), "/?id=4")

        assert [%{"sample_data" => sample_data}, _dispatch] = spans()
        assert sample_data["params"] == %{"id" => "4"}
        assert sample_data["session_data"] == %{}

        assert %{"method" => "GET", "request_path" => "/", "status" => 200} =
                 sample_data["environment"]

        assert %{
                 "request_method" => "GET",
                 "request_path" => "/",
                 "response_status" => 200,
                 "request_id" => request_id
               } = sample_data["metadata"]

        assert is_binary(request_id)
      end

      test "is tagged with the rendered template" do
        get(build_conn(), "/show?name=Phoenix")

        assert [%{"sample_data" => %{"tags" => tags}}, _dispatch, _render] = spans()

        assert tags == %{
                 "phoenix_template" => "show",
                 "phoenix_format" => "html",
                 "phoenix_view" => "AppsignalTest.Phoenix.PageHTML"
               }
      end

      test "is tagged with a template rendered inside an instrumented block" do
        get(build_conn(), "/render_in_instrument")

        assert [root | _] = spans()
        assert root["sample_data"]["tags"]["phoenix_template"] == "show"
      end

      test "has the response status of a chunked response" do
        get(build_conn(), "/chunked")

        assert [%{"name" => "AppsignalTest.Phoenix.PageController#chunked"} = root, _dispatch] =
                 spans()

        assert root["sample_data"]["environment"]["status"] == 200
      end

      test "describes the request when the action opens another root span" do
        get(build_conn(), "/nested_root")

        [request_root | _] = root_spans()
        assert request_root["name"] == "AppsignalTest.Phoenix.PageController#nested_root"
        assert request_root["sample_data"]["tags"]["phoenix_template"] == "show"
        assert request_root["sample_data"]["params"] == %{}
      end

      test "is a new one for each request in the same process" do
        get(build_conn(), "/show")
        get(build_conn(), "/users/4")

        assert [first, second] = root_spans()
        assert first["name"] == "AppsignalTest.Phoenix.PageController#show"
        assert second["name"] == "AppsignalTest.Phoenix.PageController#index"
        assert second["sample_data"]["tags"] == nil
      end

      # Pins current behaviour, not intended behaviour: a request that calls
      # Tracer.ignore/0 is still reported, without its name. See
      # https://github.com/appsignal/appsignal-elixir/issues/1089.
      test "is still recorded, without its name, when the action calls Tracer.ignore/0" do
        assert get(build_conn(), "/ignored").resp_body =~ "Hello, ignored!"

        assert [%{"name" => "", "closed" => true}, %{"closed" => true}] = spans()
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end

      # Pins current behaviour, not intended behaviour: the endpoint span stays
      # open when a pipeline halts without sending a response. See
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the endpoint span after a pipeline halts without a response"
      test "stays open when a router pipeline halts without sending a response" do
        assert %Plug.Conn{halted: true, state: :unset} =
                 get(build_conn(), "/halted_without_response")

        assert [root, dispatch] = spans()
        refute root["closed"]
        assert dispatch["closed"]
      end

      # Pins current behaviour, not intended behaviour: the root span closes when
      # a chunked response starts, before the action streams it. See
      # https://github.com/appsignal/appsignal-elixir/issues/1085.
      test "closes before the action streams a chunked response" do
        get(build_conn(), "/chunked")

        assert_received {:streaming, [root, dispatch]}
        assert root["closed"]
        refute dispatch["closed"]
      end
    end

    describe "the child spans recorded for a request" do
      test "include the router dispatch span, under the root" do
        get(build_conn(), "/?id=4")

        assert [root, dispatch] = spans()
        assert dispatch["parent_span_id"] == root["span_id"]
        assert category(dispatch) == "call.phoenix_router_dispatch"
        assert dispatch["name"] == ""
      end

      test "include a template render, under the router dispatch span" do
        get(build_conn(), "/show?name=Phoenix")

        assert [_root, dispatch, render] = spans()
        assert render["parent_span_id"] == dispatch["span_id"]

        assert render["name"] ==
                 ~s[Render "show" (html) template from AppsignalTest.Phoenix.PageHTML]

        assert category(render) == "render.phoenix_template"
      end

      test "include an instrumented block, with the template rendered inside it under it" do
        get(build_conn(), "/render_in_instrument")

        assert [_root, dispatch, group, render] = spans()
        assert group["name"] == "event.group"
        assert group["parent_span_id"] == dispatch["span_id"]
        assert render["parent_span_id"] == group["span_id"]
      end

      test "include an instrumented block the action redirects from" do
        assert %Plug.Conn{status: 302} = get(build_conn(), "/redirect_in_instrument")

        assert [_root, _dispatch, %{"name" => "event.group"}] = spans()
      end

      test "include a decorated action's span, with its render under it" do
        get(build_conn(), "/decorated")

        assert [_root, dispatch, decorated, render] = spans()
        assert decorated["name"] == "AppsignalTest.Phoenix.PageController.decorated_2"
        assert decorated["parent_span_id"] == dispatch["span_id"]
        assert render["parent_span_id"] == decorated["span_id"]
      end

      test "include a second router dispatch for a request forwarded to another Phoenix router" do
        get(build_conn(), "/forwarded_to_phoenix")

        assert [_root, outer, inner] = spans()
        assert inner["parent_span_id"] == outer["span_id"]
        assert category(inner) == "call.phoenix_router_dispatch"
      end

      test "include the error page's render when no route matches" do
        get(build_conn(), "/missing")

        assert [root, render] = spans()
        assert render["parent_span_id"] == root["span_id"]
        assert render["name"] =~ ~s(Render "404")
      end
    end

    describe "requests that record no span" do
      test "halted before Plug.Telemetry" do
        assert %Plug.Conn{status: 403} = get(build_conn(), "/halt_in_endpoint")
        assert spans() == []
      end
    end

    # Pins current behaviour, not intended behaviour: the router dispatch span
    # stays open after the request raises. See
    # https://github.com/appsignal/appsignal-elixir/issues/1084.
    describe "a request that raises in its action" do
      setup do
        assert_raise RuntimeError, fn -> get(build_conn(), "/exception?id=4") end
        :ok
      end

      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records the error on the closed root span" do
        assert [root, _dispatch] = spans()
        assert root["closed"]
        assert root["name"] == "AppsignalTest.Phoenix.PageController#exception"

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Exception!"} =
                 root["error"]

        assert root["sample_data"]["params"] == %{"id" => "4"}
      end

      # Pins current behaviour, not intended behaviour: the error sample has no
      # response status. See
      # https://github.com/appsignal/appsignal-elixir/issues/1093.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records the request without its response status" do
        assert [root, _dispatch] = spans()
        assert root["sample_data"]["environment"]["status"] == nil
      end

      @tag leaves_spans_open: "the router dispatch span after an error"
      test "leaves the router dispatch span open" do
        assert [%{"closed" => true}, %{"closed" => false} = dispatch] = spans()
        assert category(dispatch) == "call.phoenix_router_dispatch"
      end

      @tag leaves_spans_open: "the router dispatch span after an error"
      test "ignores the rest of the process's trace" do
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end
    end

    describe "a request that fails in its action in other ways" do
      # Pins current behaviour, not intended behaviour: the router dispatch span
      # stays open after the request raises. See
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records a Phoenix.ActionClauseError on a root span named after the action" do
        assert_raise Phoenix.ActionClauseError, fn -> get(build_conn(), "/only_one?id=2") end

        assert [root, _dispatch] = spans()
        assert root["name"] == "AppsignalTest.Phoenix.PageController#only_one"
        assert root["error"]["name"] == "Phoenix.ActionClauseError"
      end

      # Pins current behaviour, not intended behaviour: the router dispatch span
      # stays open after the request raises. See
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records an error raised while rendering a template" do
        assert_raise ArgumentError, fn -> get(build_conn(), "/broken_template") end

        assert [root, dispatch, render] = spans()
        assert root["error"]["name"] == "ArgumentError"
        assert render["closed"]
        refute dispatch["closed"]
      end

      # Pins current behaviour, not intended behaviour: an exit or a throw leaves
      # the root span without a name, and the router dispatch span open. See
      # https://github.com/appsignal/appsignal-elixir/issues/1086 and
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records an exit as an ErlangError, without the request's name" do
        assert :exited = catch_exit(get(build_conn(), "/exit"))

        assert [root, _dispatch] = spans()
        assert root["name"] == ""
        assert root["error"]["name"] == "ErlangError"
      end

      # Pins current behaviour, not intended behaviour: an exit or a throw leaves
      # the root span without a name, and the router dispatch span open. See
      # https://github.com/appsignal/appsignal-elixir/issues/1086 and
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records a throw as an ErlangError, without the request's name" do
        assert :thrown = catch_throw(get(build_conn(), "/throw"))

        assert [root, _dispatch] = spans()
        assert root["name"] == ""
        assert root["error"]["name"] == "ErlangError"
      end

      # Pins current behaviour, not intended behaviour: an error below 500 is
      # recorded, and the router dispatch span stays open. See
      # https://github.com/appsignal/appsignal-elixir/issues/1087 and
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the router dispatch span after an error"
      test "records an error below 500 raised in an action" do
        assert_raise Plug.BadRequestError, fn -> get(build_conn(), "/bad_request") end

        assert [root, _dispatch] = spans()
        assert root["name"] == "AppsignalTest.Phoenix.PageController#bad_request"
        assert root["error"]["name"] == "Plug.BadRequestError"
      end
    end

    # Pins current behaviour, not intended behaviour: a plug that raises in the
    # endpoint or in a router pipeline leaves a span open, and its error is not
    # recorded. See https://github.com/appsignal/appsignal-elixir/issues/1084.
    describe "a request that raises in a plug" do
      @tag leaves_spans_open: "the endpoint span after a plug in the endpoint raises"
      test "leaves the root span open without the error when a plug in the endpoint raises" do
        assert_raise RuntimeError, "Exception in the endpoint!", fn ->
          get(build_conn(), "/raise_in_endpoint")
        end

        assert [root, render] = spans()
        refute root["closed"]
        assert root["error"] == nil
        assert render["parent_span_id"] == root["span_id"]
        assert render["name"] =~ ~s(Render "500")
      end

      @tag leaves_spans_open: "the endpoint span after a plug in the endpoint raises"
      test "leaves the root span open when the request body fails to parse" do
        conn = Plug.Conn.put_req_header(build_conn(), "content-type", "application/json")

        assert_raise Plug.Parsers.ParseError, fn -> post(conn, "/", "{") end

        assert [root, render] = spans()
        refute root["closed"]
        assert root["error"] == nil
        assert render["parent_span_id"] == root["span_id"]
        assert render["name"] =~ ~s(Render "400")
      end

      @tag leaves_spans_open: "the router dispatch span after a pipeline plug raises"
      test "records the request without the error when a pipeline plug raises" do
        assert_raise RuntimeError, "Exception in a pipeline!", fn ->
          get(build_conn(), "/raise_in_pipeline")
        end

        assert [root, dispatch, _render] = spans()
        assert root["closed"]
        assert root["name"] == "GET /raise_in_pipeline"
        assert root["sample_data"]["environment"]["status"] == 500
        assert root["error"] == nil
        refute dispatch["closed"]
      end

      @tag leaves_spans_open: "the router dispatch span after a pipeline plug raises"
      test "leaves the router dispatch span open when CSRF protection rejects the request" do
        conn = Plug.Conn.put_private(build_conn(), :plug_skip_csrf_protection, false)

        assert_raise Plug.CSRFProtection.InvalidCSRFTokenError, fn -> post(conn, "/csrf") end

        assert [root, dispatch, _render] = spans()
        assert root["closed"]
        assert root["name"] == "POST /csrf"
        assert root["sample_data"]["environment"]["status"] == 403
        assert root["error"] == nil
        refute dispatch["closed"]
      end
    end

    describe "a request through an endpoint mounted in another endpoint" do
      setup do
        start_supervised!(MountingEndpoint)
        :ok
      end

      test "records the mounted endpoint's span under the outer one" do
        assert %Plug.Conn{status: 200} =
                 dispatch(build_conn(), MountingEndpoint, :get, "/users/4")

        assert [root, mounted, dispatch] = spans()
        assert root["name"] == "AppsignalTest.Phoenix.PageController#index"
        assert mounted["parent_span_id"] == root["span_id"]
        assert category(mounted) == "call.phoenix_endpoint"
        assert dispatch["parent_span_id"] == mounted["span_id"]
      end

      # Pins current behaviour, not intended behaviour: when a plug in the
      # mounted endpoint raises, the outer endpoint's span stays open, without
      # the error. See https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the outer endpoint span after a plug in the mounted one raises"
      test "leaves the outer endpoint span open when a plug in the mounted endpoint raises" do
        assert_raise RuntimeError, "Exception in the endpoint!", fn ->
          dispatch(build_conn(), MountingEndpoint, :get, "/raise_in_endpoint")
        end

        assert [root, mounted, _render] = spans()
        refute root["closed"]
        assert root["error"] == nil
        assert mounted["closed"]
      end

      # Pins current behaviour, not intended behaviour: when the action raises,
      # the mounted endpoint's span and the router dispatch span stay open. See
      # https://github.com/appsignal/appsignal-elixir/issues/1084.
      @tag leaves_spans_open: "the mounted endpoint and router dispatch spans after an error"
      test "leaves the mounted endpoint and router dispatch spans open when the action raises" do
        assert_raise RuntimeError, "Exception!", fn ->
          dispatch(build_conn(), MountingEndpoint, :get, "/exception")
        end

        assert [root, mounted, dispatch] = spans()
        assert root["error"]["name"] == "RuntimeError"
        refute mounted["closed"]
        refute dispatch["closed"]
      end
    end
  end

  defmodule Appsignal.Phoenix.EventHandlerServerTest do
    use AppsignalTest.IntegrationCase

    # The same requests through each web server Phoenix runs on. A server can
    # serve more than one request in a process, and turns exceptions into
    # error responses itself.
    for {app, endpoint} <- [
          bandit: AppsignalTest.Phoenix.BanditEndpoint,
          plug_cowboy: AppsignalTest.Phoenix.CowboyEndpoint
        ],
        Appsignal.Dependencies.present?(app) do
      describe "requests served by #{app}" do
        setup do
          start_supervised!({Phoenix.PubSub, name: AppsignalTest.Phoenix.PubSub})
          start_supervised!(unquote(endpoint))
          {:ok, _} = Application.ensure_all_started(:inets)
          [endpoint: unquote(endpoint)]
        end

        test "records each request on its own root span", %{endpoint: endpoint} do
          assert {200, "<p>Hello, World!</p>"} = http_get(endpoint, "/show")
          assert {200, "Welcome to Phoenix!"} = http_get(endpoint, "/users/4")

          spans = await_spans()

          assert [
                   "AppsignalTest.Phoenix.PageController#show",
                   "AppsignalTest.Phoenix.PageController#index"
                 ] = Enum.map(root_spans(spans), & &1["name"])
        end

        # Pins current behaviour, not intended behaviour: the router dispatch
        # span stays open after the request raises. See
        # https://github.com/appsignal/appsignal-elixir/issues/1084.
        @tag leaves_spans_open: "the router dispatch span after an error"
        test "responds to an error with the error page", %{endpoint: endpoint} do
          assert {500, "Internal Server Error"} = http_get(endpoint, "/exception")
        end

        # Pins current behaviour, not intended behaviour: the router dispatch
        # span stays open after the request raises. See
        # https://github.com/appsignal/appsignal-elixir/issues/1084.
        @tag leaves_spans_open: "the router dispatch span after an error"
        test "records the error on the root span", %{endpoint: endpoint} do
          http_get(endpoint, "/exception")

          [root | _] =
            await_spans(fn spans -> match?([%{"closed" => true} | _], root_spans(spans)) end)

          assert root["error"]["name"] == "RuntimeError"
        end

        # Pins current behaviour, not intended behaviour: the router dispatch
        # span stays open after the request raises. See
        # https://github.com/appsignal/appsignal-elixir/issues/1084.
        @tag leaves_spans_open: "the router dispatch span after an error"
        test "records a request after a failed one", %{endpoint: endpoint} do
          assert {500, _} = http_get(endpoint, "/exception")
          assert {200, _} = http_get(endpoint, "/users/4")

          spans =
            await_spans(fn spans ->
              length(Enum.filter(root_spans(spans), & &1["closed"])) == 2
            end)

          assert [
                   %{"name" => "AppsignalTest.Phoenix.PageController#exception"},
                   %{"name" => "AppsignalTest.Phoenix.PageController#index", "error" => nil}
                 ] = root_spans(spans)
        end

        @tag leaves_spans_open: "the spans of a request whose awaited task raises"
        test "responds with an error to a request whose awaited task raises", %{
          endpoint: endpoint
        } do
          assert {500, _} = http_get(endpoint, "/task_exception")
        end

        if app == :bandit do
          # Pins current behaviour, not intended behaviour: when a task the
          # action awaits raises, Bandit records the error on a root span
          # without a name and leaves the router dispatch span open. See
          # https://github.com/appsignal/appsignal-elixir/issues/1086 and
          # https://github.com/appsignal/appsignal-elixir/issues/1084.
          @tag leaves_spans_open: "the router dispatch span after an error"
          test "records the error of an awaited task without the request's name", %{
            endpoint: endpoint
          } do
            http_get(endpoint, "/task_exception")

            [root, dispatch] =
              await_spans(fn spans -> match?([%{"closed" => true}, _], spans) end)

            assert root["name"] == ""
            assert root["error"]["name"] == "ErlangError"
            assert root["error"]["message"] =~ "Exception in a task!"
            refute dispatch["closed"]
          end

          # Pins current behaviour, not intended behaviour: Bandit serves a
          # connection's requests from one process, so Tracer.ignore/0 carries
          # over to the next request. See
          # https://github.com/appsignal/appsignal-elixir/issues/1089.
          test "records no request after an ignored one on the same connection", %{
            endpoint: endpoint
          } do
            assert [200, 200] = keep_alive_get(endpoint, ["/ignored", "/users/4"])

            assert [%{"name" => ""}, _dispatch] =
                     await_spans(&match?([%{"closed" => true}, %{"closed" => true}], &1))
          end

          # Pins current behaviour, not intended behaviour: Bandit serves a
          # connection's requests from one process, so a span left open becomes
          # the parent of the next request. See
          # https://github.com/appsignal/appsignal-elixir/issues/1089.
          @tag leaves_spans_open: "the span the first request leaves open"
          test "records a request after one that leaves a span open under that span", %{
            endpoint: endpoint
          } do
            assert [200, 200] = keep_alive_get(endpoint, ["/leak", "/users/4"])

            [_root, dispatch, leaked, next_root, _next_dispatch] =
              await_spans(&match?([_, _, _, %{"closed" => true}, %{"closed" => true}], &1))

            assert leaked["parent_span_id"] == dispatch["span_id"]
            refute leaked["closed"]
            assert next_root["parent_span_id"] == leaked["span_id"]
            assert next_root["name"] == ""
          end
        else
          # Pins current behaviour, not intended behaviour: when a task the
          # action awaits raises, Cowboy stops the request's process, which
          # leaves its spans open without the error. See
          # https://github.com/appsignal/appsignal-elixir/issues/1088.
          @tag leaves_spans_open: "the spans of a request whose process Cowboy stops"
          test "leaves the spans of a request whose awaited task raises open, without the error",
               %{endpoint: endpoint} do
            http_get(endpoint, "/task_exception")

            assert [root, dispatch] = await_spans(&match?([_, _], &1))
            refute root["closed"]
            assert root["error"] == nil
            refute dispatch["closed"]
          end

          test "records a request after an ignored one on the same connection", %{
            endpoint: endpoint
          } do
            assert [200, 200] = keep_alive_get(endpoint, ["/ignored", "/users/4"])

            spans = await_spans(&(length(&1) == 4 and all_closed?(&1)))

            assert ["", "AppsignalTest.Phoenix.PageController#index"] =
                     Enum.map(root_spans(spans), & &1["name"])
          end

          @tag leaves_spans_open: "the span the first request leaves open"
          test "records a request after one that leaves a span open on its own root span", %{
            endpoint: endpoint
          } do
            assert [200, 200] = keep_alive_get(endpoint, ["/leak", "/users/4"])

            [_root, dispatch, leaked, next_root, _next_dispatch] =
              await_spans(&match?([_, _, _, %{"closed" => true}, %{"closed" => true}], &1))

            assert leaked["parent_span_id"] == dispatch["span_id"]
            refute leaked["closed"]
            assert next_root["parent_span_id"] == ""
            assert next_root["name"] == "AppsignalTest.Phoenix.PageController#index"
          end
        end
      end
    end

    defp keep_alive_get(endpoint, paths) do
      {:ok, {_address, port}} = endpoint.server_info(:http)
      AppsignalTest.KeepAliveClient.get(port, paths)
    end

    defp http_get(endpoint, path) do
      {:ok, {_address, port}} = endpoint.server_info(:http)
      url = ~c"http://127.0.0.1:#{port}#{path}"

      {:ok, {{_, status, _}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])

      {status, to_string(body)}
    end
  end

  defmodule Appsignal.Phoenix.EventHandlerAttachTest do
    use ExUnit.Case
    import AppsignalTest.IntegrationCase, only: [attached?: 2]
    import AppsignalTest.Utils, only: [with_config: 2, with_frozen_environment: 1]

    @events [
      [:phoenix, :endpoint, :start],
      [:phoenix, :endpoint, :stop],
      [:phoenix, :router_dispatch, :start],
      [:phoenix, :router_dispatch, :stop],
      [:phoenix, :router_dispatch, :exception],
      [:phoenix, :controller, :render, :start],
      [:phoenix, :controller, :render, :stop],
      [:phoenix, :controller, :render, :exception]
    ]

    describe "attaching the :telemetry handlers" do
      test "attaches to Phoenix's endpoint, router dispatch and render events" do
        for event <- @events do
          assert attached?(Appsignal.Phoenix.EventHandler, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_phoenix set to false" do
      setup do
        for event <- @events do
          :telemetry.detach({Appsignal.Phoenix.EventHandler, event})
        end

        with_config(%{instrument_phoenix: false}, fn -> Appsignal.start([], []) end)
        on_exit(fn -> Appsignal.Phoenix.EventHandler.attach() end)
      end

      test "does not attach to Phoenix's endpoint, router dispatch and render events" do
        for event <- @events do
          refute attached?(Appsignal.Phoenix.EventHandler, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with appsignal_phoenix 2.x installed" do
      setup do
        for event <- @events do
          :telemetry.detach({Appsignal.Phoenix.EventHandler, event})
        end

        :ok =
          :application.load(
            {:application, :appsignal_phoenix,
             [vsn: ~c"2.8.2", modules: [], registered: [], applications: []]}
          )

        with_frozen_environment(fn ->
          ExUnit.CaptureLog.capture_log(fn -> Appsignal.start([], []) end)
        end)

        on_exit(fn ->
          Application.unload(:appsignal_phoenix)
          Appsignal.Phoenix.EventHandler.attach()
        end)
      end

      test "does not attach to Phoenix's endpoint, router dispatch and render events" do
        for event <- @events do
          refute attached?(Appsignal.Phoenix.EventHandler, event)
        end
      end
    end
  end
end
