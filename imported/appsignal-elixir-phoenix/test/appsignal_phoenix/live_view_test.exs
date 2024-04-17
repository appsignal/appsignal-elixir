defmodule Appsignal.Phoenix.LiveViewTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)

    %{
      socket: %Phoenix.LiveView.Socket{
        endpoint: PhoenixWeb.Endpoint,
        id: 1,
        private: %{
          root_view: PhoenixWeb.LiveView
        },
        router: PhoenixWeb.Router,
        view: PhoenixWeb.LiveView
      }
    }
  end

  describe "instrument/4" do
    setup %{socket: socket} do
      %{return: PhoenixWeb.LiveView.mount(%{}, socket)}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert {:ok, %Phoenix.LiveView.Socket{}} = return
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "PhoenixWeb.LiveView#mount"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "live_view"}]} = Test.Span.get(:set_namespace)
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "endpoint" => PhoenixWeb.Endpoint,
        "id" => 1,
        "root_view" => PhoenixWeb.LiveView,
        "router" => PhoenixWeb.Router,
        "view" => PhoenixWeb.LiveView
      })
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/4, when a root span exists" do
    setup %{socket: socket} do
      %{
        parent: Appsignal.Tracer.create_span("live_view"),
        return: PhoenixWeb.LiveView.mount(%{}, socket)
      }
    end

    test "creates a child span", %{parent: parent} do
      assert {:ok, [{_, ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "live_view"}]} = Test.Span.get(:set_namespace)
    end
  end

  describe "instrument/4, with a non-private root_view" do
    setup %{socket: _socket} do
      %{
        return:
          PhoenixWeb.LiveView.mount(%{}, %{
            __struct__: Phoenix.LiveView.Socket,
            endpoint: PhoenixWeb.Endpoint,
            id: 1,
            root_view: PhoenixWeb.LiveView,
            router: PhoenixWeb.Router,
            view: PhoenixWeb.LiveView
          })
      }
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "endpoint" => PhoenixWeb.Endpoint,
        "id" => 1,
        "root_view" => PhoenixWeb.LiveView,
        "router" => PhoenixWeb.Router,
        "view" => PhoenixWeb.LiveView
      })
    end
  end

  describe "instrument/5" do
    setup %{socket: socket} do
      %{return: PhoenixWeb.LiveView.mount(%{"body" => "Hello world!"}, socket)}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert {:ok, %Phoenix.LiveView.Socket{}} = return
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "PhoenixWeb.LiveView#mount"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "live_view"}]} = Test.Span.get(:set_namespace)
    end

    test "sets the span's parameters" do
      assert_sample_data("params", %{"body" => "Hello world!"})
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "endpoint" => PhoenixWeb.Endpoint,
        "id" => 1,
        "root_view" => PhoenixWeb.LiveView,
        "router" => PhoenixWeb.Router,
        "view" => PhoenixWeb.LiveView
      })
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/5, when an error is raised" do
    setup %{socket: socket} do
      try do
        PhoenixWeb.LiveView.mount(%{"body" => "Exception!"}, socket)
      catch
        kind, reason -> %{kind: kind, reason: reason, stack: __STACKTRACE__}
      end
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "PhoenixWeb.LiveView#mount"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "live_view"}]} = Test.Span.get(:set_namespace)
    end

    test "sets the span's parameters" do
      assert_sample_data("params", %{"body" => "Exception!"})
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "endpoint" => PhoenixWeb.Endpoint,
        "id" => 1,
        "root_view" => PhoenixWeb.LiveView,
        "router" => PhoenixWeb.Router,
        "view" => PhoenixWeb.LiveView
      })
    end

    test "reraises the error", %{kind: kind, reason: reason} do
      assert kind == :error
      assert %RuntimeError{} = reason
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "ignores the process in the registry" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "attach/0" do
    setup do
      Appsignal.Phoenix.LiveView.attach()

      on_exit(fn ->
        :ok =
          :telemetry.detach({Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :mount, :start]})

        :ok =
          :telemetry.detach({Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :mount, :stop]})

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :mount, :exception]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_params, :start]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_params, :stop]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_params, :exception]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_event, :start]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_event, :stop]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :handle_event, :exception]}
          )

        :ok =
          :telemetry.detach({Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :render, :start]})

        :ok =
          :telemetry.detach({Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :render, :stop]})

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_view, :render, :exception]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :handle_event, :start]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :handle_event, :stop]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :handle_event, :exception]}
          )
      end)
    end

    test "attach/0 attaches to LiveView events" do
      assert attached?([:phoenix, :live_view, :mount, :start])
      assert attached?([:phoenix, :live_view, :mount, :stop])
      assert attached?([:phoenix, :live_view, :mount, :exception])
      assert attached?([:phoenix, :live_view, :handle_params, :start])
      assert attached?([:phoenix, :live_view, :handle_params, :stop])
      assert attached?([:phoenix, :live_view, :handle_params, :exception])
      assert attached?([:phoenix, :live_view, :handle_event, :start])
      assert attached?([:phoenix, :live_view, :handle_event, :stop])
      assert attached?([:phoenix, :live_view, :handle_event, :exception])
      assert attached?([:phoenix, :live_view, :render, :start])
      assert attached?([:phoenix, :live_view, :render, :stop])
      assert attached?([:phoenix, :live_view, :render, :exception])
      assert attached?([:phoenix, :live_component, :handle_event, :start])
      assert attached?([:phoenix, :live_component, :handle_event, :stop])
      assert attached?([:phoenix, :live_component, :handle_event, :exception])
    end
  end

  describe "handle_event_start/4, with a mount event" do
    setup do
      event = [:phoenix, :live_view, :mount, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__}
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Appsignal.Phoenix.LiveViewTest#mount"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "appsignal:category" and data == "mount.live_view"
             end)
    end

    test "sets the span's params" do
      assert {:ok, attributes} = Test.Span.get(:set_sample_data)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "params" and data == %{foo: "bar"}
             end)
    end

    test "sets the span's session data" do
      assert {:ok, attributes} = Test.Span.get(:set_sample_data)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "session_data" and data == %{bar: "baz"}
             end)
    end
  end

  describe "handle_event_start/4, with a handle_event event" do
    setup do
      event = [:phoenix, :live_view, :handle_event, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_view, :handle_event, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          event: "event"
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Appsignal.Phoenix.LiveViewTest#handle_event"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "appsignal:category" and data == "handle_event.live_view"
             end)
    end

    test "sets the span's event name" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "event" and data == "event"
             end)
    end

    test "sets the span's params" do
      assert {:ok, attributes} = Test.Span.get(:set_sample_data)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "params" and data == %{foo: "bar"}
             end)
    end
  end

  describe "handle_event_start/4, with a live_component handle_event event" do
    setup do
      event = [:phoenix, :live_component, :handle_event, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_component, :handle_event, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__}
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Appsignal.Phoenix.LiveViewTest#handle_event"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "appsignal:category" and data == "handle_event.live_view"
             end)
    end

    test "sets the span's params" do
      assert {:ok, attributes} = Test.Span.get(:set_sample_data)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "params" and data == %{foo: "bar"}
             end)
    end
  end

  describe "handle_event_stop/4" do
    setup do
      event = [:phoenix, :live_view, :mount, :stop]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_event_stop/4,
        :ok
      )

      Appsignal.Tracer.create_span("live_view")

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :stop],
        %{},
        %{}
      )
    end

    test "closes the span with an end time" do
      assert {:ok, [{%Span{}, [end_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event_exception/4" do
    setup do
      event = [:phoenix, :live_view, :mount, :exception]
      reason = %RuntimeError{message: "Exception!"}

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_event_exception/4,
        :ok
      )

      Appsignal.Tracer.create_span("live_view")

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :exception],
        %{},
        %{kind: :error, reason: reason, stacktrace: []}
      )

      [reason: reason]
    end

    test "adds an error to the current span", %{reason: reason} do
      assert {:ok, [{%Span{}, :error, ^reason, []}]} = Test.Span.get(:add_error)
    end

    test "closes the span with an end time" do
      assert {:ok, [{%Span{}, [end_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:close_span)
    end

    test "ignores the process in the registry" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  defp assert_sample_data(asserted_key, asserted_data) do
    {:ok, sample_data} = Test.Span.get(:set_sample_data_if_nil)

    assert Enum.any?(sample_data, fn {%Span{}, key, data} ->
             key == asserted_key and data == asserted_data
           end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.filter(fn handler ->
      {module, _} = handler.id
      module == Appsignal.Phoenix.LiveView
    end)
    |> length() == 1
  end
end
