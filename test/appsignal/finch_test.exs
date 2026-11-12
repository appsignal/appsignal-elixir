if Appsignal.Dependencies.present?(:plug_cowboy) do
  defmodule Appsignal.FinchTest do
    use AppsignalTest.IntegrationCase
    alias AppsignalTest.HTTPServer
    import AppsignalTest.Utils, only: [with_config: 2]

    setup do
      start_supervised!(HTTPServer)
      start_supervised!({Finch, name: AppsignalTest.Finch})
      :ok
    end

    describe "sending a request through Finch" do
      test "sends the request" do
        assert {:ok, %Finch.Response{status: 200, body: "OK"}} =
                 instrumented(fn -> request(:get, HTTPServer.url("/users/4?page=2")) end)

        assert [%{method: "GET", path: "/users/4?page=2"}] = HTTPServer.requests()
      end

      test "sends the request's method and body" do
        instrumented(fn -> request(:post, HTTPServer.url("/users"), "name=Alice") end)

        assert [%{method: "POST", body: "name=Alice"}] = HTTPServer.requests()
      end

      test "returns Finch's error for a refused connection" do
        assert {:error, %{__exception__: true, reason: :econnrefused}} =
                 instrumented(fn -> request(:get, HTTPServer.refused_url()) end)
      end

      test "raises the response handler's error" do
        assert_raise RuntimeError, "Stream!", fn -> instrumented(&raising_stream/0) end
      end
    end

    describe "the span recorded for a request" do
      test "is a child span named after the method and origin" do
        instrumented(fn -> request(:get, HTTPServer.url("/users/4?page=2")) end)

        [parent] = root_spans()
        assert [span] = children(spans(), parent)
        assert span["name"] == "GET #{HTTPServer.origin(HTTPServer.url())}"
        assert category(span) == "request.finch"
        assert span["error"] == nil
      end

      test "is named after the request's method" do
        instrumented(fn -> request(:post, HTTPServer.url("/users"), "name=Alice") end)

        assert [_span] = named(spans(), "POST #{HTTPServer.origin(HTTPServer.url())}")
      end

      test "is a child of the innermost span" do
        Appsignal.instrument("outer", fn ->
          Appsignal.instrument("inner", fn -> request(:get, HTTPServer.url()) end)
        end)

        [inner] = named(spans(), "inner")
        assert [%{"name" => "GET " <> _}] = children(spans(), inner)
      end

      test "has no error for an error response" do
        assert {:ok, %Finch.Response{status: 500}} =
                 instrumented(fn -> request(:get, HTTPServer.url("/status/500")) end)

        assert [%{"error" => nil}] =
                 named(spans(), "GET #{HTTPServer.origin(HTTPServer.url())}")
      end

      test "has no error for a refused connection" do
        url = HTTPServer.refused_url()
        instrumented(fn -> request(:get, url) end)

        assert [%{"error" => nil}] = named(spans(), "GET #{HTTPServer.origin(url)}")
      end

      test "has no error when the response handler raises" do
        assert_raise RuntimeError, fn -> instrumented(&raising_stream/0) end

        assert [%{"error" => nil}] =
                 named(spans(), "GET #{HTTPServer.origin(HTTPServer.url())}")
      end
    end

    describe "requests that record no span" do
      test "outside an instrumented function" do
        assert {:ok, %Finch.Response{status: 200}} = request(:get, HTTPServer.url())
        assert spans() == []
      end

      test "from the AppsignalFinch pool" do
        # The AppsignalFinch pool connects with TLS options, so a plain HTTP
        # request through it exits.
        assert :badarg =
                 catch_exit(
                   instrumented(fn ->
                     :get |> Finch.build(HTTPServer.url()) |> Finch.request(AppsignalFinch)
                   end)
                 )

        assert [%{"name" => "parent"}] = spans()
      end

      test "from a standalone transmitter's pool" do
        instrumented(fn ->
          assert {:ok, %Finch.Response{status: 200}} =
                   Appsignal.Transmitter.request_standalone(:get, HTTPServer.url())
        end)

        assert [%{"name" => "parent"}] = spans()
      end

      test "from a pool whose name starts with AppsignalFinch" do
        start_supervised!({Finch, name: AppsignalFinchClient})

        instrumented(fn ->
          assert {:ok, %Finch.Response{status: 200}} =
                   :get |> Finch.build(HTTPServer.url()) |> Finch.request(AppsignalFinchClient)
        end)

        assert [%{"name" => "parent"}] = spans()
      end

      test "made asynchronously" do
        instrumented(fn ->
          ref = :get |> Finch.build(HTTPServer.url()) |> Finch.async_request(AppsignalTest.Finch)
          assert_receive {^ref, :done}
        end)

        assert [%{"name" => "parent"}] = spans()
        assert [%{method: "GET"}] = HTTPServer.requests()
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to Finch's request events" do
        for event <- events() do
          assert attached?(Appsignal.Finch, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_finch set to false" do
      setup do
        Enum.each(events(), &:telemetry.detach({Appsignal.Finch, &1}))
        with_config(%{instrument_finch: false}, fn -> Appsignal.start([], []) end)
        :ok
      end

      @tag :detaches_handlers
      test "does not attach to Finch's request events" do
        for event <- events() do
          refute attached?(Appsignal.Finch, event)
        end
      end

      @tag :detaches_handlers
      test "records no span for a request" do
        instrumented(fn -> request(:get, HTTPServer.url()) end)
        assert [%{"name" => "parent"}] = spans()
      end
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp request(method, url, body \\ nil) do
      method
      |> Finch.build(url, [], body)
      |> Finch.request(AppsignalTest.Finch)
    end

    defp raising_stream do
      :get
      |> Finch.build(HTTPServer.url())
      |> Finch.stream(AppsignalTest.Finch, nil, fn _chunk, _acc -> raise "Stream!" end)
    end

    defp events do
      [[:finch, :request, :start], [:finch, :request, :stop], [:finch, :request, :exception]]
    end
  end
end
