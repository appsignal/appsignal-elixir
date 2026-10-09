defmodule Appsignal.Phoenix.EventHandlerRequestTest do
  # Tests the event handler against whole request sequences, rather than against
  # pairs of events in isolation.
  #
  # `Plug.Telemetry` emits the endpoint stop event from a `register_before_send`
  # callback, so it fires inside whatever code sends the response. That is why
  # the endpoint stop event appears in the middle of these sequences instead of
  # at the end.
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)

    # No root span is created here on purpose. In a Phoenix application that
    # does not `use Appsignal.Plug`, the endpoint span is the root span.
    :ok
  end

  describe "after a request" do
    setup do
      endpoint_start()
      router_dispatch_start()
      render_start()
      render_stop()
      endpoint_stop()
      router_dispatch_stop()
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request that renders inside an instrumented block" do
    setup do
      endpoint_start()
      endpoint_span = Tracer.current_span()

      router_dispatch_start()

      Appsignal.instrument("event.group", fn _span ->
        render_start()
        render_stop()
        endpoint_stop()
      end)

      router_dispatch_stop()

      [endpoint_span: endpoint_span]
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end

    test "closes the endpoint span", %{endpoint_span: endpoint_span} do
      {:ok, calls} = Test.Tracer.get(:close_span)

      assert Enum.any?(calls, fn
               {^endpoint_span} -> true
               _ -> false
             end)
    end
  end

  describe "after a request that redirects inside an instrumented block" do
    # The shape of a `redirect(conn, to: ...) |> halt()` inside a function
    # decorated with `transaction_event()`. The response is sent, and therefore
    # the endpoint stop event fires, before the instrumented block returns.
    setup do
      endpoint_start()
      router_dispatch_start()

      Appsignal.instrument("event.group", fn _span ->
        endpoint_stop()
      end)

      router_dispatch_stop()
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after two requests in the same process" do
    # Bandit serves every keep-alive request on a connection from one process,
    # so a second request can start in a process that has already served one.
    setup do
      endpoint_start()
      router_dispatch_start()

      Appsignal.instrument("event.group", fn _span ->
        endpoint_stop()
      end)

      router_dispatch_stop()

      endpoint_start()
    end

    test "starts a root span for the second request" do
      # `Appsignal.Test.Tracer` records calls with the most recent one first.
      assert {:ok, [{"http_request", nil} | _]} = Test.Tracer.get(:create_span)
    end
  end

  describe "after a request that is halted before it reaches the router" do
    setup do
      endpoint_start()
      endpoint_stop()
    end

    test "sets the root span's parameters" do
      {:ok, calls} = Test.Span.get(:set_sample_data_if_nil)

      assert [{%Span{}, "params", %{"foo" => "bar"}}] =
               Enum.filter(calls, fn {_span, key, _value} -> key == "params" end)
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a routed request, then one halted before the router" do
    # Both requests run in the same process, as they do on Bandit. The second
    # one never reaches the router, so it has no route of its own.
    setup do
      endpoint_start()
      router_dispatch_start()
      endpoint_stop()
      router_dispatch_stop()

      endpoint_start()
      endpoint_stop(conn_without_route_info())
    end

    test "does not name the second request after the first request's route" do
      {:ok, calls} = Test.Span.get(:set_name_if_nil)
      names = Enum.map(calls, fn {_span, name} -> name end)

      refute "GET /" in names
    end
  end

  describe "after an endpoint request, then a router dispatch without an endpoint" do
    # A Plug application that forwards to a Phoenix router emits the router
    # dispatch events without the endpoint ones. The endpoint request before it
    # must not stop the router dispatch from describing the root span.
    setup do
      endpoint_start()
      router_dispatch_start()
      endpoint_stop()
      router_dispatch_stop()

      router_dispatch_start()
      router_dispatch_stop()
    end

    test "describes the root span of both requests" do
      {:ok, calls} = Test.Span.get(:set_name_if_nil)

      assert length(calls) == 2
    end
  end

  describe "after a forwarded router dispatch without an endpoint" do
    # Nested router dispatch events, with no endpoint events around them. Only
    # the first dispatch stop to run should describe the root span.
    setup do
      router_dispatch_start()
      router_dispatch_start()
      router_dispatch_stop()
      router_dispatch_stop()
    end

    test "describes the root span once" do
      {:ok, calls} = Test.Span.get(:set_name_if_nil)

      assert length(calls) == 1
    end
  end

  describe "after a request that is dispatched through a forwarded router" do
    # `Phoenix.Router.forward` re-enters the router, so the router dispatch
    # events nest.
    setup do
      endpoint_start()
      router_dispatch_start()
      router_dispatch_start()
      endpoint_stop()
      router_dispatch_stop()
      router_dispatch_stop()
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request that renders and responds inside a nested root span" do
    # The shape of a controller that calls a function decorated with
    # `transaction()`, which renders and sends the response.
    setup do
      endpoint_start()
      endpoint_span = Tracer.current_span()

      router_dispatch_start()

      Appsignal.Instrumentation.instrument_root("background_job", "Worker.run", fn ->
        render_start()
        render_stop()
        endpoint_stop()
      end)

      router_dispatch_stop()

      [endpoint_span: endpoint_span]
    end

    test "names the request's root span", %{endpoint_span: endpoint_span} do
      assert {:ok, [{^endpoint_span, "AppsignalPhoenixExampleWeb.PageController#index"}]} =
               Test.Span.get(:set_name_if_nil)
    end

    test "sets the request's parameters on its root span", %{endpoint_span: endpoint_span} do
      {:ok, calls} = Test.Span.get(:set_sample_data_if_nil)

      assert [{^endpoint_span, "params", %{"foo" => "bar"}}] =
               Enum.filter(calls, fn {_span, key, _value} -> key == "params" end)
    end

    test "sets the template tags on the request's root span", %{endpoint_span: endpoint_span} do
      {:ok, calls} = Test.Span.get(:set_sample_data_if_nil)

      assert [{^endpoint_span, "tags", %{"phoenix_template" => "template"}}] =
               Enum.filter(calls, fn {_span, key, _value} -> key == "tags" end)
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request that is dispatched to the router inside a nested root span" do
    # The shape of an endpoint plug that calls the router from a function
    # decorated with `transaction()`.
    setup do
      endpoint_start()
      endpoint_span = Tracer.current_span()

      Appsignal.Instrumentation.instrument_root("background_job", "Worker.run", fn ->
        router_dispatch_start()
        endpoint_stop()
        router_dispatch_stop()
      end)

      [endpoint_span: endpoint_span]
    end

    test "names the request's root span", %{endpoint_span: endpoint_span} do
      assert {:ok, [{^endpoint_span, "AppsignalPhoenixExampleWeb.PageController#index"}]} =
               Test.Span.get(:set_name_if_nil)
    end
  end

  describe "after a router dispatch without an endpoint that renders inside a nested root span" do
    setup do
      router_dispatch_start()
      dispatch_span = Tracer.current_span()

      Appsignal.Instrumentation.instrument_root("background_job", "Worker.run", fn ->
        render_start()
        render_stop()
      end)

      router_dispatch_stop()

      [dispatch_span: dispatch_span]
    end

    test "sets the template tags on the request's root span", %{dispatch_span: dispatch_span} do
      {:ok, calls} = Test.Span.get(:set_sample_data_if_nil)

      assert [{^dispatch_span, "tags", %{"phoenix_template" => "template"}}] =
               Enum.filter(calls, fn {_span, key, _value} -> key == "tags" end)
    end
  end

  describe "after a request that raises before the router, with a span left open" do
    # `Phoenix.Endpoint.RenderErrors` renders the error page with the endpoint's
    # own conn, so no endpoint stop event arrives.
    setup do
      endpoint_start()
      endpoint_span = Tracer.current_span()
      router_dispatch_start()
      leaked = Tracer.create_span("http_request", Tracer.current_span())
      error_rendered()

      [endpoint_span: endpoint_span, leaked: leaked]
    end

    test "keeps none of the request's spans in the handler's bookkeeping" do
      assert Process.get({Appsignal.Phoenix.EventHandler, :endpoint_spans}) == nil
      assert Process.get({Appsignal.Phoenix.EventHandler, :router_dispatch_spans}) == nil
    end

    test "closes the endpoint span and the span left open", %{
      endpoint_span: endpoint_span,
      leaked: leaked
    } do
      closed = Test.Nif.get!(:close_span) |> Enum.map(&elem(&1, 0))
      assert endpoint_span.reference in closed
      assert leaked.reference in closed
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request through nested endpoints that raises before the router" do
    setup do
      endpoint_start()
      outer = Tracer.current_span()
      endpoint_start()
      inner = Tracer.current_span()
      error_rendered()

      [outer: outer, inner: inner]
    end

    test "closes both endpoint spans", %{outer: outer, inner: inner} do
      closed = Test.Nif.get!(:close_span) |> Enum.map(&elem(&1, 0))
      assert outer.reference in closed
      assert inner.reference in closed
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request that raises before the router, then another request" do
    setup do
      endpoint_start()
      router_dispatch_start()
      error_rendered()

      endpoint_start()
      router_dispatch_start()
      router_dispatch_stop()
    end

    test "starts a root span for the second request" do
      # `Appsignal.Test.Tracer` records calls with the most recent one first.
      {:ok, calls} = Test.Tracer.get(:create_span)
      assert {"http_request", nil} = Enum.at(calls, 1)
    end
  end

  describe "after a request whose controller raises, with the error page rendered" do
    # `Phoenix.Endpoint.RenderErrors` renders the error page after the router
    # dispatch exception event, in the same process.
    setup do
      endpoint_start()
      router_dispatch_start()
      router_dispatch_exception()
      render_start()
      render_stop()
      error_rendered()
    end

    test "creates no span for the error page" do
      {:ok, calls} = Test.Tracer.get(:create_span)
      assert length(calls) == 2
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request with a span left open in the controller" do
    # The router dispatch stop event fires after the controller has returned.
    setup do
      endpoint_start()
      router_dispatch_start()
      leaked = Tracer.create_span("http_request", Tracer.current_span())
      endpoint_stop()
      router_dispatch_stop()

      [leaked: leaked]
    end

    test "closes the span left open", %{leaked: leaked} do
      closed = Test.Nif.get!(:close_span) |> Enum.map(&elem(&1, 0))
      assert leaked.reference in closed
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request rejected in a router pipeline" do
    # A plug in a router pipeline, such as `Plug.CSRFProtection`, raises before
    # the controller. No router dispatch stop or exception event follows, and
    # sending the error page fires the endpoint stop event first.
    setup do
      endpoint_start()
      router_dispatch_start()
      dispatch_span = Tracer.current_span()
      endpoint_stop()
      error_rendered()

      [dispatch_span: dispatch_span]
    end

    test "closes the router dispatch span", %{dispatch_span: dispatch_span} do
      closed = Test.Nif.get!(:close_span) |> Enum.map(&elem(&1, 0))
      assert dispatch_span.reference in closed
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  describe "after a request whose controller raises while rendering" do
    setup do
      endpoint_start()
      router_dispatch_start()
      dispatch_span = Tracer.current_span()
      render_start()
      render_span = Tracer.current_span()
      router_dispatch_exception()

      [dispatch_span: dispatch_span, render_span: render_span]
    end

    test "does not ignore the trace" do
      refute Enum.any?(
               Appsignal.Test.Nif.get(:set_span_attribute_bool) |> elem_or_empty(),
               &match?({_, "appsignal.ignore_trace", _}, &1)
             )
    end

    test "closes the dispatch and render spans", %{
      dispatch_span: dispatch_span,
      render_span: render_span
    } do
      closed = Test.Nif.get!(:close_span) |> Enum.map(&elem(&1, 0))
      assert dispatch_span.reference in closed
      assert render_span.reference in closed
    end

    test "leaves no spans behind" do
      assert [] == Tracer.lookup(self())
    end
  end

  defp router_dispatch_exception do
    :telemetry.execute(
      [:phoenix, :router_dispatch, :exception],
      %{duration: 49_474_000},
      %{conn: conn(), reason: %RuntimeError{message: "Exception!"}, stacktrace: []}
    )
  end

  defp error_rendered do
    :telemetry.execute(
      [:phoenix, :error_rendered],
      %{duration: 49_474_000},
      %{
        conn: conn(),
        status: 500,
        kind: :error,
        reason: %RuntimeError{message: "Exception!"},
        stacktrace: [],
        log: :error
      }
    )
  end

  defp endpoint_start do
    :telemetry.execute(
      [:phoenix, :endpoint, :start],
      %{system_time: -576_460_736_044_040_000},
      %{conn: %Plug.Conn{private: %{phoenix_endpoint: PhoenixWeb.Endpoint}}, options: []}
    )
  end

  defp endpoint_stop(conn \\ conn()) do
    # `Plug.Telemetry` emits this event with only the conn and its own options.
    # It does not include the route.
    :telemetry.execute(
      [:phoenix, :endpoint, :stop],
      %{duration: 49_474_000},
      %{conn: conn, options: []}
    )
  end

  defp router_dispatch_start do
    :telemetry.execute(
      [:phoenix, :router_dispatch, :start],
      %{system_time: -576_460_736_044_040_000},
      %{
        conn: %Plug.Conn{private: %{phoenix_endpoint: PhoenixWeb.Endpoint}},
        plug: AppsignalPhoenixExampleWeb.PageController,
        plug_opts: :index,
        route: "/",
        path_params: %{},
        pipe_through: [:browser],
        log: :info
      }
    )
  end

  defp router_dispatch_stop do
    :telemetry.execute(
      [:phoenix, :router_dispatch, :stop],
      %{duration: 49_474_000},
      %{
        conn: conn(),
        plug: AppsignalPhoenixExampleWeb.PageController,
        plug_opts: :index,
        route: "/foo/:bar",
        path_params: %{},
        pipe_through: [:browser],
        log: :info
      }
    )
  end

  defp render_start do
    :telemetry.execute(
      [:phoenix, :controller, :render, :start],
      %{system_time: -576_460_736_044_040_000},
      %{view: PhoenixWeb.View, template: "template", format: "html"}
    )
  end

  defp render_stop do
    :telemetry.execute([:phoenix, :controller, :render, :stop], %{duration: 49_474_000}, %{})
  end

  defp conn do
    %Plug.Conn{
      params: %{"foo" => "bar"},
      private: %{
        phoenix_action: :index,
        phoenix_controller: AppsignalPhoenixExampleWeb.PageController
      },
      port: 80,
      request_path: "/",
      status: 200
    }
  end

  defp conn_without_route_info do
    %Plug.Conn{
      params: %{"foo" => "bar"},
      private: %{},
      port: 80,
      request_path: "/",
      status: 200
    }
  end

  defp elem_or_empty({:ok, list}), do: list
  defp elem_or_empty(:error), do: []
end
