defmodule Appsignal.Phoenix.EventHandlerTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}

  setup do
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)

    :ok
  end

  describe "after receiving an endpoint-start event" do
    setup [:create_root_span, :endpoint_start_event]

    test "starts a child span", %{span: parent} do
      assert {:ok, [{"http_request", ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's category" do
      assert {:ok, [{%Span{}, "appsignal:category", "call.phoenix_endpoint"}]} =
               Test.Span.get(:set_attribute)
    end
  end

  describe "after receiving an endpoint-start and an endpoint-stop event" do
    setup [:create_root_span, :endpoint_start_event, :endpoint_finish_event]

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "AppsignalPhoenixExampleWeb.PageController#index"}]} =
               Test.Span.get(:set_name)
    end

    test "finishes an event" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "sets the root span's sample data" do
      {:ok, calls} = Test.Span.get(:set_sample_data)

      [{%Span{}, "environment", environment}] =
        Enum.filter(calls, fn {_span, key, _value} -> key == "environment" end)

      assert %{
               "host" => "www.example.com",
               "method" => "GET",
               "port" => 80,
               "request_id" => nil,
               "request_path" => "/",
               "status" => 200
             } == environment
    end
  end

  describe "after receiving an endpoint-start and an router_dispatch-exception event" do
    setup [:create_root_span, :endpoint_start_event]

    setup do
      :telemetry.execute(
        [:phoenix, :router_dispatch, :exception],
        %{duration: 49_474_000},
        %{
          conn: conn(),
          reason: %RuntimeError{},
          stack: [],
          options: []
        }
      )
    end

    test "sets the root span's name" do
      assert {:ok, [{%Span{}, "AppsignalPhoenixExampleWeb.PageController#index"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the root span's error" do
      assert {:ok, [{%Span{}, :error, %RuntimeError{}, []}]} = Test.Span.get(:add_error)
    end

    test "closes the root span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "sets the root span's sample data" do
      {:ok, calls} = Test.Span.get(:set_sample_data)

      [{%Span{}, "environment", environment}] =
        Enum.filter(calls, fn {_span, key, _value} -> key == "environment" end)

      assert %{
               "host" => "www.example.com",
               "method" => "GET",
               "port" => 80,
               "request_id" => nil,
               "request_path" => "/",
               "status" => 200
             } == environment
    end
  end

  describe "after receiving an endpoint-start and a wrapped router_dispatch-exception event" do
    setup [:create_root_span, :endpoint_start_event]

    setup do
      :telemetry.execute(
        [:phoenix, :router_dispatch, :exception],
        %{duration: 49_474_000},
        %{
          reason: %Plug.Conn.WrapperError{
            conn: conn(),
            reason: %RuntimeError{},
            stack: []
          },
          options: []
        }
      )
    end

    test "sets the root span's name" do
      assert {:ok, [{%Span{}, "AppsignalPhoenixExampleWeb.PageController#index"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the root span's error" do
      assert {:ok, [{%Span{}, :error, %RuntimeError{}, []}]} = Test.Span.get(:add_error)
    end

    test "closes the root span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "after receiving an render-start event" do
    setup [:create_root_span, :render_start_event]

    test "starts a child span", %{span: parent} do
      assert {:ok, [{"http_request", ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Render \"template\" (html) template from PhoenixWeb.View"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, [{%Span{}, "appsignal:category", "render.phoenix_template"}]} =
               Test.Span.get(:set_attribute)
    end
  end

  describe "after receiving an render-start and an render-stop event" do
    setup [:create_root_span, :render_start_event, :render_finish_event]

    test "finishes an event" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "after receiving an render-start and an render-exception event" do
    setup [:create_root_span, :render_start_event, :render_exception_event]

    test "finishes an event" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp create_root_span(_context) do
    [span: Tracer.create_span("http_request")]
  end

  def endpoint_start_event(_context) do
    :telemetry.execute(
      [:phoenix, :endpoint, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: %Plug.Conn{private: %{phoenix_endpoint: PhoenixWeb.Endpoint}},
        options: []
      }
    )
  end

  def endpoint_finish_event(_context) do
    :telemetry.execute(
      [:phoenix, :endpoint, :stop],
      %{duration: 49_474_000},
      %{conn: conn(), options: []}
    )
  end

  def render_start_event(_context) do
    :telemetry.execute(
      [:phoenix, :controller, :render, :start],
      %{time: -576_460_736_044_040_000},
      %{view: PhoenixWeb.View, template: "template", format: "html"}
    )
  end

  def render_finish_event(_context) do
    :telemetry.execute(
      [:phoenix, :controller, :render, :stop],
      %{duration: 49_474_000},
      %{}
    )
  end

  def render_exception_event(_context) do
    :telemetry.execute(
      [:phoenix, :controller, :render, :exception],
      %{duration: 49_474_000},
      %{}
    )
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
end
