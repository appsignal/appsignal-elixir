if Appsignal.Dependencies.present?(:tesla) and Appsignal.Dependencies.present?(:plug_cowboy) do
  Application.put_env(:tesla, :disable_deprecated_builder_warning, true)

  defmodule AppsignalTest.TeslaToServer do
    @moduledoc false
    @behaviour Tesla.Middleware

    # Sends the request to AppsignalTest.HTTPServer, whatever host its URL
    # names. The clients below run it last, after Tesla.Middleware.Telemetry
    # has seen the URL their span is named after.
    @impl true
    def call(env, next, _opts) do
      server = URI.parse(AppsignalTest.HTTPServer.url())

      url =
        URI.to_string(%{
          URI.parse(env.url)
          | scheme: "http",
            host: server.host,
            port: server.port
        })

      Tesla.run(%{env | url: url}, next)
    end
  end

  defmodule TeslaClientWithPathParams do
    use Tesla

    adapter(Tesla.Adapter.Mint)

    plug(Tesla.Middleware.BaseUrl, "https://example.com/api")
    plug(Tesla.Middleware.Telemetry)
    plug(Tesla.Middleware.PathParams)
    plug(AppsignalTest.TeslaToServer)
  end

  defmodule TeslaClientWithPathParamsFirst do
    use Tesla

    adapter(Tesla.Adapter.Mint)

    plug(Tesla.Middleware.BaseUrl, "https://example.com/api")
    plug(Tesla.Middleware.PathParams)
    plug(Tesla.Middleware.Telemetry)
    plug(AppsignalTest.TeslaToServer)
  end

  defmodule TeslaClientWithBaseUrlLast do
    use Tesla

    adapter(Tesla.Adapter.Mint)

    plug(Tesla.Middleware.Telemetry)
    plug(Tesla.Middleware.PathParams)
    plug(Tesla.Middleware.BaseUrl, "https://example.com/api")
    plug(AppsignalTest.TeslaToServer)
  end

  defmodule TeslaClientWithoutTelemetry do
    use Tesla

    adapter(Tesla.Adapter.Mint)

    plug(Tesla.Middleware.BaseUrl, "https://example.com/api")
    plug(AppsignalTest.TeslaToServer)
  end

  defmodule Appsignal.TeslaTest do
    use AppsignalTest.IntegrationCase
    alias AppsignalTest.HTTPServer
    import AppsignalTest.Utils, only: [with_config: 2]

    setup do
      start_supervised!(HTTPServer)
      :ok
    end

    describe "sending a request through Tesla" do
      test "sends the request from a use Tesla module" do
        assert {:ok, %Tesla.Env{status: 200, body: "OK"}} =
                 instrumented(fn ->
                   TeslaClientWithPathParams.get("/users/:id", opts: [path_params: [id: 4]])
                 end)

        assert [%{method: "GET", path: "/api/users/4"}] = HTTPServer.requests()
      end

      test "sends the request from a runtime client" do
        client =
          Tesla.client(
            [
              {Tesla.Middleware.BaseUrl, "https://example.com/api"},
              Tesla.Middleware.Telemetry,
              Tesla.Middleware.PathParams,
              AppsignalTest.TeslaToServer
            ],
            Tesla.Adapter.Mint
          )

        assert {:ok, %Tesla.Env{status: 200}} =
                 instrumented(fn ->
                   Tesla.post(client, "/users/:id", "name=Alice", opts: [path_params: [id: 4]])
                 end)

        assert [%{method: "POST", path: "/api/users/4", body: "name=Alice"}] =
                 HTTPServer.requests()
      end

      test "returns the adapter's error for a refused connection" do
        client = Tesla.client([Tesla.Middleware.Telemetry], Tesla.Adapter.Mint)

        assert {:error, _reason} =
                 instrumented(fn -> Tesla.get(client, HTTPServer.refused_url()) end)
      end

      test "raises a later middleware's error" do
        assert_raise RuntimeError, "Middleware!", fn ->
          instrumented(fn -> Tesla.get(raising_client(), HTTPServer.url()) end)
        end
      end
    end

    describe "the span recorded for a request" do
      test "is a child span named after the templated URL" do
        instrumented(fn ->
          TeslaClientWithPathParams.get("/users/:id", opts: [path_params: [id: 4]])
        end)

        [parent] = root_spans()
        assert [span] = children(spans(), parent)
        assert span["name"] == "GET https://example.com/api/users/:id"
        assert category(span) == "request.tesla"
        assert span["error"] == nil
      end

      test "is named after an OpenAPI-style templated URL" do
        instrumented(fn ->
          TeslaClientWithPathParams.get("/users/{id}", opts: [path_params: [id: 4]])
        end)

        assert [_span] = named(spans(), "GET https://example.com/api/users/{id}")
      end

      test "is named after the origin when PathParams runs before Telemetry" do
        instrumented(fn ->
          TeslaClientWithPathParamsFirst.get("/users/:id", opts: [path_params: [id: 4]])
        end)

        assert [_span] = named(spans(), "GET https://example.com")
      end

      test "is named after the templated URL when BaseUrl runs after Telemetry" do
        instrumented(fn ->
          TeslaClientWithBaseUrlLast.get("/users/:id", opts: [path_params: [id: 4]])
        end)

        assert [_span] = named(spans(), "GET https://example.com/api/users/:id")
      end

      test "is named after the origin of a URL that overrides the base URL" do
        instrumented(fn ->
          TeslaClientWithPathParams.get("https://other.example.com/users/:id",
            opts: [path_params: [id: 4]]
          )
        end)

        assert [_span] = named(spans(), "GET https://other.example.com/users/:id")
      end

      test "leaves the query out of its name" do
        instrumented(fn -> TeslaClientWithPathParams.get("/users", query: [page: 2]) end)

        assert [_span] = named(spans(), "GET https://example.com/api/users")
      end

      test "is a child span named after the templated URL, for a runtime client with Telemetry before PathParams" do
        client =
          Tesla.client(
            [
              {Tesla.Middleware.BaseUrl, "https://example.com/api"},
              Tesla.Middleware.Telemetry,
              Tesla.Middleware.PathParams,
              AppsignalTest.TeslaToServer
            ],
            Tesla.Adapter.Mint
          )

        instrumented(fn ->
          Tesla.post(client, "/users/:id", "name=Alice", opts: [path_params: [id: 4]])
        end)

        [parent] = root_spans()
        assert [span] = children(spans(), parent)
        assert span["name"] == "POST https://example.com/api/users/:id"
        assert category(span) == "request.tesla"
      end

      test "is named after the origin, for a runtime client with PathParams before Telemetry" do
        client =
          Tesla.client(
            [
              {Tesla.Middleware.BaseUrl, "https://example.com/api"},
              Tesla.Middleware.PathParams,
              Tesla.Middleware.Telemetry,
              AppsignalTest.TeslaToServer
            ],
            Tesla.Adapter.Mint
          )

        instrumented(fn -> Tesla.get(client, "/users/:id", opts: [path_params: [id: 4]]) end)

        assert [_span] = named(spans(), "GET https://example.com")
      end

      test "is named after the base URL, for a runtime client with BaseUrl after Telemetry" do
        client =
          Tesla.client(
            [
              Tesla.Middleware.Telemetry,
              {Tesla.Middleware.BaseUrl, "https://example.com/api"},
              AppsignalTest.TeslaToServer
            ],
            Tesla.Adapter.Mint
          )

        instrumented(fn -> Tesla.get(client, "/users/4") end)

        assert [_span] = named(spans(), "GET https://example.com/api")
      end

      test "is named after the origin, for a runtime client without BaseUrl or PathParams" do
        client =
          Tesla.client(
            [Tesla.Middleware.Telemetry, AppsignalTest.TeslaToServer],
            Tesla.Adapter.Mint
          )

        instrumented(fn -> Tesla.get(client, "https://example.com/api/users/4") end)

        assert [_span] = named(spans(), "GET https://example.com")
      end

      test "is named after the templated URL, for a runtime client with a function middleware" do
        client =
          Tesla.client(
            [
              fn env, next -> Tesla.run(env, next) end,
              {Tesla.Middleware.BaseUrl, "https://example.com/api"},
              Tesla.Middleware.Telemetry,
              Tesla.Middleware.PathParams,
              AppsignalTest.TeslaToServer
            ],
            Tesla.Adapter.Mint
          )

        instrumented(fn -> Tesla.get(client, "/users/:id", opts: [path_params: [id: 4]]) end)

        assert [_span] = named(spans(), "GET https://example.com/api/users/:id")
      end

      test "has no error for an error response" do
        assert {:ok, %Tesla.Env{status: 500}} =
                 instrumented(fn -> TeslaClientWithPathParams.get("/status/500") end)

        assert [%{"error" => nil}] =
                 named(spans(), "GET https://example.com/api/status/500")
      end

      test "has no error for a refused connection" do
        client = Tesla.client([Tesla.Middleware.Telemetry], Tesla.Adapter.Mint)
        url = HTTPServer.refused_url()

        instrumented(fn -> Tesla.get(client, url) end)

        assert [%{"error" => nil}] = named(spans(), "GET #{HTTPServer.origin(url)}")
      end

      test "has no error when a later middleware raises" do
        assert_raise RuntimeError, fn ->
          instrumented(fn -> Tesla.get(raising_client(), HTTPServer.url()) end)
        end

        assert [%{"error" => nil}] = named(spans(), "GET #{HTTPServer.origin(HTTPServer.url())}")
      end

      # Pins current behaviour, not intended behaviour: a request through the
      # Finch adapter is recorded by both the Tesla and the Finch integration.
      # See https://github.com/appsignal/appsignal-elixir/issues/1078.
      test "is recorded twice, as nested spans, for a request through the Finch adapter" do
        start_supervised!({Finch, name: AppsignalTest.TeslaFinch})

        client =
          Tesla.client(
            [Tesla.Middleware.Telemetry],
            {Tesla.Adapter.Finch, name: AppsignalTest.TeslaFinch}
          )

        assert {:ok, %Tesla.Env{status: 200}} =
                 instrumented(fn -> Tesla.get(client, HTTPServer.url("/users/4")) end)

        [parent] = root_spans()
        assert [tesla] = children(spans(), parent)
        assert category(tesla) == "request.tesla"
        assert [finch] = children(spans(), tesla)
        assert category(finch) == "request.finch"
        assert finch["name"] == tesla["name"]
      end
    end

    describe "requests that record no span" do
      test "outside an instrumented function" do
        assert {:ok, %Tesla.Env{status: 200}} = TeslaClientWithPathParams.get("/users")
        assert spans() == []
      end

      test "without the Telemetry middleware" do
        assert {:ok, %Tesla.Env{status: 200}} =
                 instrumented(fn -> TeslaClientWithoutTelemetry.get("/users") end)

        assert [%{"name" => "parent"}] = spans()
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to Tesla's request events" do
        for event <- events() do
          assert attached?(Appsignal.Tesla, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_tesla set to false" do
      setup do
        Enum.each(events(), &:telemetry.detach({Appsignal.Tesla, &1}))
        with_config(%{instrument_tesla: false}, fn -> Appsignal.start([], []) end)
        :ok
      end

      @tag :detaches_handlers
      test "does not attach to Tesla's request events" do
        for event <- events() do
          refute attached?(Appsignal.Tesla, event)
        end
      end

      @tag :detaches_handlers
      test "records no span for a request" do
        instrumented(fn -> TeslaClientWithPathParams.get("/users") end)
        assert [%{"name" => "parent"}] = spans()
      end
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp raising_client do
      Tesla.client(
        [Tesla.Middleware.Telemetry, fn _env, _next -> raise "Middleware!" end],
        Tesla.Adapter.Mint
      )
    end

    defp events do
      [[:tesla, :request, :start], [:tesla, :request, :stop], [:tesla, :request, :exception]]
    end
  end
end

defmodule Appsignal.FakeTeslaBuilder do
  # A mock of a module that uses `Tesla.Builder` (`use Tesla`),
  # implementing `__middleware__`.
  def __middleware__ do
    [
      {Appsignal.FakeTeslaBuilderMiddleware, :call}
    ]
  end
end

defmodule Appsignal.Tesla.UnitTest do
  use ExUnit.Case

  describe "path_params?/1" do
    test "is false when the Telemetry middleware is absent" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.PathParams, nil}
             ])
    end

    test "is false when the PathParams middleware is absent" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.Telemetry, nil}
             ])
    end

    test "is false when the PathParams middleware appears before the Telemetry middleware" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.PathParams, nil},
               {Tesla.Middleware.Telemetry, nil}
             ])
    end

    test "is true when the Telemetry middleware appears before the PathParams middleware" do
      assert Appsignal.Tesla.path_params?([
               {Tesla.Middleware.Telemetry, nil},
               {Tesla.Middleware.PathParams, nil}
             ])
    end
  end

  describe "sanitise_url/3, with no base URL" do
    test "when use_full_path is false, it keeps the scheme, host and port" do
      assert "https://hex.pm" ==
               Appsignal.Tesla.sanitise_url(
                 "https://hex.pm/packages/appsignal",
                 nil,
                 false
               )
    end

    test "when use_full_path is true, it keeps the scheme, host, port and path" do
      assert "https://hex.pm/packages/appsignal" ==
               Appsignal.Tesla.sanitise_url(
                 "https://hex.pm/packages/appsignal",
                 nil,
                 true
               )
    end
  end

  describe "sanitise_url/3, with a base URL" do
    test "when the URL has a host, the base URL is ignored" do
      assert "https://appsignal.com" ==
               Appsignal.Tesla.sanitise_url(
                 "https://appsignal.com/docs",
                 "https://hex.pm/packages",
                 false
               )
    end

    test "when the URL does not have a host, the base URL's scheme, host, port and path are used" do
      assert "https://hex.pm/packages" ==
               Appsignal.Tesla.sanitise_url(
                 "/appsignal",
                 "https://hex.pm/packages",
                 false
               )
    end

    test "when use_full_path is true, the paths are joined" do
      assert "https://hex.pm/packages/:package" ==
               Appsignal.Tesla.sanitise_url(
                 "/:package",
                 "https://hex.pm/packages",
                 true
               )
    end
  end

  describe "env_middlewares/1" do
    test "it concatenates and normalises middlewares from the module and the client" do
      env =
        env([
          {Appsignal.FakeTeslaClientMiddleware, :call, :some_argument}
        ])

      assert Appsignal.Tesla.env_middlewares(env) == [
               # Normalised three element tuple middleware
               {Appsignal.FakeTeslaClientMiddleware, :some_argument},
               # Normalised two element tuple middleware
               {Appsignal.FakeTeslaBuilderMiddleware, nil}
             ]
    end

    test "it removes function adapters from the middleware chain" do
      env =
        env([
          {:fn, fn -> nil end},
          {:fn, fn _ -> nil end}
        ])

      assert Appsignal.Tesla.env_middlewares(env) == [
               {Appsignal.FakeTeslaBuilderMiddleware, nil}
             ]
    end
  end

  defp env(client_middlewares) do
    %{
      __module__: Appsignal.FakeTeslaBuilder,
      __client__: %{pre: client_middlewares},
      method: :get,
      url: nil
    }
  end
end
