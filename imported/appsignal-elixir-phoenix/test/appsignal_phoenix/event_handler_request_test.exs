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
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)

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
end
