if Appsignal.Dependencies.present?(:phoenix) do
  defmodule Appsignal.Phoenix.PlugPhoenixTest do
    # How the Plug and Phoenix instrumentation combine, for applications that
    # still `use Appsignal.Plug` in their Phoenix endpoint, as the setup for
    # older AppSignal for Phoenix versions told them to.
    use AppsignalTest.IntegrationCase
    import Phoenix.ConnTest

    @endpoint AppsignalTest.Phoenix.EndpointWithAppsignalPlug

    setup do
      start_supervised!({Phoenix.PubSub, name: AppsignalTest.Phoenix.PubSub})
      start_supervised!(@endpoint)
      start_supervised!(AppsignalTest.Phoenix.Endpoint)
      :ok
    end

    describe "handling a request, compared with an endpoint without Appsignal.Plug" do
      test "responds as the endpoint without Appsignal.Plug does" do
        for path <- ["/", "/show", "/halted", "/forwarded_to_plug", "/missing"] do
          with_plug = get(build_conn(), path)
          without = dispatch(build_conn(), AppsignalTest.Phoenix.Endpoint, :get, path)
          assert {with_plug.status, with_plug.resp_body} == {without.status, without.resp_body}
        end
      end
    end

    describe "the root span recorded for a request" do
      test "is Appsignal.Plug's, with the endpoint span under it" do
        get(build_conn(), "/show")

        assert [root, endpoint, dispatch, render] = spans()
        assert root["parent_span_id"] == ""
        assert category(root) == "call.phoenix"
        assert root["name"] == "AppsignalTest.Phoenix.PageController#show"
        assert root["sample_data"]["tags"]["phoenix_template"] == "show"
        assert endpoint["parent_span_id"] == root["span_id"]
        assert category(endpoint) == "call.phoenix_endpoint"
        assert dispatch["parent_span_id"] == endpoint["span_id"]
        assert render["parent_span_id"] == dispatch["span_id"]
      end

      test "is Appsignal.Plug's alone for a request halted before Plug.Telemetry" do
        assert %Plug.Conn{status: 403} = get(build_conn(), "/halt_in_endpoint")

        assert [root] = spans()
        assert root["name"] == ""
        assert category(root) == "call.phoenix"
        assert root["sample_data"]["environment"]["status"] == 403
      end
    end

    # Pins current behaviour, not intended behaviour: with Appsignal.Plug in the
    # endpoint, the root span has no category and the Phoenix spans stay open
    # after an error. See
    # https://github.com/appsignal/appsignal-elixir/issues/1083.
    describe "a request that raises in its action" do
      setup do
        assert_raise RuntimeError, fn -> get(build_conn(), "/exception") end
        :ok
      end

      @tag leaves_spans_open: "the endpoint and router dispatch spans after an error"
      test "records the error once, on the closed root span" do
        assert [root, _endpoint, _dispatch] = spans()
        assert root["closed"]
        assert root["error"]["name"] == "RuntimeError"
        assert root["name"] == "AppsignalTest.Phoenix.PageController#exception"
      end

      @tag leaves_spans_open: "the endpoint and router dispatch spans after an error"
      test "records the root span without a category" do
        assert [root, _endpoint, _dispatch] = spans()
        assert category(root) == nil
      end

      @tag leaves_spans_open: "the endpoint and router dispatch spans after an error"
      test "leaves the endpoint and router dispatch spans open" do
        assert [_root, endpoint, dispatch] = spans()
        refute endpoint["closed"]
        refute dispatch["closed"]
      end
    end

    # Pins current behaviour, not intended behaviour: a request with no matching
    # route records an empty trace. See
    # https://github.com/appsignal/appsignal-elixir/issues/1083.
    describe "a request with no matching route" do
      setup do
        assert %Plug.Conn{status: 404} = get(build_conn(), "/missing")
        :ok
      end

      test "records an empty root span" do
        assert [root, _endpoint] = spans()
        assert root["name"] == ""
        assert root["sample_data"] == %{}
        assert root["error"] == nil
      end

      test "ignores the rest of the process's trace" do
        assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
      end
    end
  end
end
