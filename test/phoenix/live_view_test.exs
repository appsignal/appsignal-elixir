defmodule Appsignal.Phoenix.LiveViewTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  def __live__, do: %{log: :info}

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)

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
      assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
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

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :update, :start]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :update, :stop]}
          )

        :ok =
          :telemetry.detach(
            {Appsignal.Phoenix.LiveView, [:phoenix, :live_component, :update, :exception]}
          )
      end)
    end

    test "attach/0 attaches to LiveView and LiveComponent events" do
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
      assert attached?([:phoenix, :live_component, :update, :start])
      assert attached?([:phoenix, :live_component, :update, :stop])
      assert attached?([:phoenix, :live_component, :update, :exception])
    end
  end

  describe "handle_live_view_event_start/4, with a mount event" do
    setup do
      event = [:phoenix, :live_view, :mount, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_live_view_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          uri: "http://localhost/"
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

  describe "handle_live_view_event_start/4, with a handle_event event" do
    setup do
      event = [:phoenix, :live_view, :handle_event, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_live_view_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_view, :handle_event, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          event: "some_event"
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Appsignal.Phoenix.LiveViewTest#handle_event (some_event)"}]} =
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

  describe "handle_live_component_event_start/4, with a handle_event event" do
    setup do
      event = [:phoenix, :live_component, :handle_event, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_live_component_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_component, :handle_event, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          component: AppsignalTest.SomeLiveComponent,
          event: "some_event"
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "AppsignalTest.SomeLiveComponent#handle_event (some_event)"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "appsignal:category" and data == "handle_event.live_component"
             end)
    end

    test "sets the span's view tag" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "view" and data == "Appsignal.Phoenix.LiveViewTest"
             end)
    end

    test "sets the span's params" do
      assert {:ok, attributes} = Test.Span.get(:set_sample_data)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "params" and data == %{foo: "bar"}
             end)
    end
  end

  describe "handle_live_component_event_start/4, with an update event" do
    setup do
      event = [:phoenix, :live_component, :update, :start]

      :telemetry.attach(
        {__MODULE__, event},
        event,
        &Appsignal.Phoenix.LiveView.handle_live_component_event_start/4,
        :ok
      )

      :telemetry.execute(
        [:phoenix, :live_component, :update, :start],
        %{monotonic_time: -576_457_566_461_433_920, system_time: 1_653_474_764_790_125_080},
        %{
          params: %{foo: "bar"},
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          component: AppsignalTest.SomeLiveComponent,
          assigns_sockets: [{{}, %Phoenix.LiveView.Socket{view: __MODULE__}}]
        }
      )
    end

    test "creates a root span with a namespace and a start time" do
      assert {:ok, [{"live_view", nil, [start_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "AppsignalTest.SomeLiveComponent#update"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "appsignal:category" and data == "update.live_component"
             end)
    end

    test "sets the span's view tag" do
      assert {:ok, attributes} = Test.Span.get(:set_attribute)

      assert Enum.any?(attributes, fn {%Span{}, key, data} ->
               key == "view" and data == "Appsignal.Phoenix.LiveViewTest"
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
      attach_mount_handlers()

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{system_time: 1_653_474_764_790_125_080},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :stop],
        %{duration: 100_000},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )
    end

    test "closes the span with an end time" do
      assert {:ok, [{%Span{}, [end_time: 1_653_474_764_790_125_080]}]} =
               Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event_exception/4" do
    setup do
      reason = %RuntimeError{message: "Exception!"}
      attach_mount_handlers()

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{system_time: 1_653_474_764_790_125_080},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :exception],
        %{duration: 100_000},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount,
          kind: :error,
          reason: reason,
          stacktrace: []
        }
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
      assert Appsignal.Tracer.lookup(self()) == [{self(), :ignore}]
    end
  end

  describe "handle_event_stop/4, with another span opened during the event" do
    setup do
      attach_mount_handlers()

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{system_time: 1_653_474_764_790_125_080},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )

      mount = Appsignal.Tracer.current_span()
      other = Appsignal.Tracer.create_span("live_view", mount)

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :stop],
        %{duration: 100_000},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )

      [mount: mount, other: other]
    end

    test "closes the event's span", %{mount: mount} do
      {:ok, closed} = Test.Tracer.get(:close_span)
      assert Enum.any?(closed, &(elem(&1, 0) == mount))
    end

    test "leaves the other span open", %{other: other} do
      {:ok, closed} = Test.Tracer.get(:close_span)
      refute Enum.any?(closed, &(elem(&1, 0) == other))
    end
  end

  describe "handle_event_exception/4, with another span opened during the event" do
    setup do
      attach_mount_handlers()

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :start],
        %{system_time: 1_653_474_764_790_125_080},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount
        }
      )

      mount = Appsignal.Tracer.current_span()
      other = Appsignal.Tracer.create_span("live_view", mount)

      :telemetry.execute(
        [:phoenix, :live_view, :mount, :exception],
        %{duration: 100_000},
        %{
          socket: %Phoenix.LiveView.Socket{view: __MODULE__},
          params: %{foo: "bar"},
          session: %{bar: "baz"},
          uri: "http://localhost/",
          telemetry_span_context: :mount,
          kind: :error,
          reason: %RuntimeError{message: "Exception!"},
          stacktrace: []
        }
      )

      [mount: mount, other: other]
    end

    test "adds the error to the event's span", %{mount: mount} do
      assert {:ok, [{^mount, :error, %RuntimeError{}, []}]} = Test.Span.get(:add_error)
    end

    test "closes the event's span", %{mount: mount} do
      {:ok, closed} = Test.Tracer.get(:close_span)
      assert Enum.any?(closed, &(elem(&1, 0) == mount))
    end

    test "leaves the other span open", %{other: other} do
      {:ok, closed} = Test.Tracer.get(:close_span)
      refute Enum.any?(closed, &(elem(&1, 0) == other))
    end
  end

  defp attach_mount_handlers do
    for {suffix, handler} <- [
          start: &Appsignal.Phoenix.LiveView.handle_live_view_event_start/4,
          stop: &Appsignal.Phoenix.LiveView.handle_event_stop/4,
          exception: &Appsignal.Phoenix.LiveView.handle_event_exception/4
        ] do
      event = [:phoenix, :live_view, :mount, suffix]
      :telemetry.attach({__MODULE__, event}, event, handler, :ok)
      on_exit(fn -> :telemetry.detach({__MODULE__, event}) end)
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
