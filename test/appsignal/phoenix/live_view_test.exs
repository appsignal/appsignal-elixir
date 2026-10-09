if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.LiveViewHelpers do
    @moduledoc false
    import ExUnit.Callbacks

    def start_endpoint(_context) do
      start_supervised!({Phoenix.PubSub, name: AppsignalTest.Phoenix.PubSub})
      start_supervised!(AppsignalTest.Phoenix.Endpoint)
      :ok
    end

    def attach_live_view(_context) do
      Appsignal.Phoenix.LiveView.attach()
      on_exit(&detach_live_view/0)
      :ok
    end

    def detach_live_view do
      for %{id: {Appsignal.Phoenix.LiveView, _} = id} <- :telemetry.list_handlers([]) do
        :telemetry.detach(id)
      end
    end

    def live_view_spans(spans, module) do
      name = inspect(module)
      Enum.filter(spans, &String.starts_with?(&1["name"], name <> "#"))
    end

    def with_category(spans, category) do
      Enum.filter(spans, &(AppsignalTest.Spans.category(&1) == category))
    end

    # LiveView renders ids and signed session tokens that differ between views
    # and renders.
    def normalize(html) do
      html
      |> String.replace(~r/ (id|data-phx-[a-z]+)="[^"]*"/, "")
      |> String.replace(~r/phx-[A-Za-z0-9_-]+/, "phx-id")
    end
  end

  defmodule Appsignal.Phoenix.LiveViewTest do
    use AppsignalTest.IntegrationCase
    import Phoenix.ConnTest
    import Phoenix.LiveViewTest
    import AppsignalTest.LiveViewHelpers
    alias AppsignalTest.Phoenix.{CounterComponent, CounterLive}

    @endpoint AppsignalTest.Phoenix.Endpoint

    setup [:start_endpoint, :attach_live_view]

    describe "rendering a LiveView through Phoenix" do
      test "renders the LiveView over HTTP" do
        assert html_response(get(build_conn(), "/live?x=1"), 200) =~ "Count: 0"
      end

      test "renders an event's result" do
        {:ok, view, _html} = live(build_conn(), "/live?x=1")
        assert render_click(view, "increment", %{"by" => "1"}) =~ "Count: 1"
      end

      test "renders a component's event's result" do
        {:ok, view, _html} = live(build_conn(), "/live?x=1")
        assert view |> element("#component-increment") |> render_click() =~ "Component: 1"
      end

      test "crashes the LiveView with the event's error" do
        {:ok, view, _html} = live(build_conn(), "/live?x=1")
        Process.flag(:trap_exit, true)

        assert {{%RuntimeError{message: "Exception in the LiveView!"}, _stack}, _call} =
                 catch_exit(render_click(view, "raise"))
      end
    end

    describe "the spans recorded for the initial HTTP render" do
      setup do
        get(build_conn(), "/live?x=1")
        :ok
      end

      test "include a root span named after the route, with the request's parameters" do
        assert [request | _] = root_spans()
        assert request["name"] == "GET /live"
        assert request["sample_data"]["params"] == %{"x" => "1"}
      end

      test "include the static render, in the request's trace" do
        assert [request | _] = root_spans()
        assert [_dispatch, render] = in_trace(spans(), request)

        assert render["name"] ==
                 ~s(Render "template" (html\) template from Phoenix.LiveView.Static)
      end

      test "include mount, handle_params and the component's update, each as its own trace" do
        live_view = live_view_spans(spans(), CounterLive)
        component = live_view_spans(spans(), CounterComponent)

        assert ["mount.live_view", "handle_params.live_view"] = Enum.map(live_view, &category/1)
        assert ["update.live_component"] = Enum.map(component, &category/1)

        for span <- live_view ++ component do
          assert span["parent_span_id"] == ""
          assert span["namespace"] == "live_view"
        end

        assert spans() |> Enum.map(& &1["trace_id"]) |> Enum.uniq() |> length() == 4
      end
    end

    describe "the spans recorded for a connected LiveView" do
      setup do
        {:ok, view, _html} = live(build_conn(), "/live?x=1")
        [view: view]
      end

      test "include its mount, with the parameters and session", %{view: view} do
        _ = render(view)

        assert [_static, connected] =
                 spans()
                 |> live_view_spans(CounterLive)
                 |> with_category("mount.live_view")

        assert connected["name"] == "AppsignalTest.Phoenix.CounterLive#mount"
        assert connected["sample_data"]["params"] == %{"x" => "1"}
        assert is_map(connected["sample_data"]["session_data"])
      end

      test "include its renders", %{view: view} do
        _ = render(view)
        assert [_ | _] = with_category(spans(), "render.live_view")
      end

      test "include an event, with its parameters", %{view: view} do
        render_click(view, "increment", %{"by" => "1"})

        assert [event] = with_category(spans(), "handle_event.live_view")
        assert event["name"] == "AppsignalTest.Phoenix.CounterLive#handle_event (increment)"
        assert event["attributes"]["event"] == "increment"
        assert event["sample_data"]["params"] == %{"by" => "1"}
      end

      test "include a component's event, with the LiveView it belongs to", %{view: view} do
        view |> element("#component-increment") |> render_click()

        assert [event] = with_category(spans(), "handle_event.live_component")
        assert event["name"] == "AppsignalTest.Phoenix.CounterComponent#handle_event (increment)"
        assert event["attributes"]["view"] == "AppsignalTest.Phoenix.CounterLive"
      end

      test "include each callback as its own trace", %{view: view} do
        render_click(view, "increment")
        live_view = live_view_spans(spans(), CounterLive)

        assert Enum.all?(live_view, &(&1["parent_span_id"] == ""))

        assert live_view |> Enum.map(& &1["trace_id"]) |> Enum.uniq() |> length() ==
                 length(live_view)
      end

      test "include an event with the error raised in it", %{view: view} do
        Process.flag(:trap_exit, true)
        catch_exit(render_click(view, "raise"))

        assert [event] = with_category(spans(), "handle_event.live_view")
        assert event["error"]["name"] == "RuntimeError"
      end

      test "include a component's event with the error raised in it", %{view: view} do
        Process.flag(:trap_exit, true)
        catch_exit(view |> element("#component-raise") |> render_click())

        assert [event] = with_category(spans(), "handle_event.live_component")
        assert event["error"]["name"] == "RuntimeError"
      end
    end
  end

  defmodule Appsignal.Phoenix.LiveViewInstrumentTest do
    use AppsignalTest.IntegrationCase
    import Phoenix.ConnTest
    import Phoenix.LiveViewTest
    import AppsignalTest.LiveViewHelpers
    alias AppsignalTest.Phoenix.ManualLive

    @endpoint AppsignalTest.Phoenix.Endpoint

    setup :start_endpoint

    describe "rendering a LiveView with the instrument helpers, compared with one without them" do
      test "renders as the LiveView without them does" do
        {:ok, view, html} = live(build_conn(), "/live/manual")
        {:ok, uninstrumented, uninstrumented_html} = live(build_conn(), "/live/uninstrumented")

        assert normalize(html) == normalize(uninstrumented_html)

        assert normalize(render_click(view, "increment")) ==
                 normalize(render_click(uninstrumented, "increment"))
      end

      test "crashes the LiveView with the event's error" do
        {:ok, view, _html} = live(build_conn(), "/live/manual")
        Process.flag(:trap_exit, true)

        assert {{%RuntimeError{message: "Exception in the LiveView!"}, _}, _} =
                 catch_exit(render_click(view, "raise"))
      end
    end

    describe "the spans recorded with the instrument helpers" do
      setup do
        {:ok, view, _html} = live(build_conn(), "/live/manual")
        [view: view]
      end

      test "include the mount, as a root span in the live_view namespace" do
        assert [_static, connected] = live_view_spans(spans(), ManualLive)
        assert connected["name"] == "AppsignalTest.Phoenix.ManualLive#mount"
        assert connected["attributes"]["appsignal.namespace"] == "live_view"
        assert connected["parent_span_id"] == ""
        assert category(connected) == "AppsignalTest.Phoenix.ManualLive#mount"

        assert %{"view" => "Elixir.AppsignalTest.Phoenix.ManualLive"} =
                 connected["sample_data"]["environment"]
      end

      test "include an event, with its parameters", %{view: view} do
        render_click(view, "increment", %{"by" => "1"})

        assert [event] = named(spans(), "AppsignalTest.Phoenix.ManualLive#handle_event")
        assert event["sample_data"]["params"] == %{"by" => "1"}
      end

      test "include an event with the error raised in it", %{view: view} do
        Process.flag(:trap_exit, true)
        catch_exit(render_click(view, "raise"))

        assert [event] = named(spans(), "AppsignalTest.Phoenix.ManualLive#handle_event")
        assert event["error"]["name"] == "RuntimeError"
      end
    end

    describe "the spans recorded with the instrument helpers and the automatic instrumentation" do
      setup :attach_live_view

      setup do
        {:ok, view, _html} = live(build_conn(), "/live/manual")
        [view: view]
      end

      test "include each callback twice, the helper's span inside the automatic one" do
        assert [automatic, helper | _] =
                 spans() |> live_view_spans(ManualLive) |> Enum.drop(2)

        assert category(automatic) == "mount.live_view"
        assert helper["parent_span_id"] == automatic["span_id"]
      end

      # Pins current behaviour, not intended behaviour: with the instrument/5
      # helpers and attach/0 both instrumenting a callback, the automatic event
      # span stays open when the helper's block raises. See
      # https://github.com/appsignal/appsignal-elixir/issues/1082.
      @tag leaves_spans_open: "the automatic event span when the helper's block raises"
      test "leave the automatic event span open when the helper's block raises", %{view: view} do
        Process.flag(:trap_exit, true)
        catch_exit(render_click(view, "raise"))

        [automatic, helper] =
          raise_event_spans(await_spans(&match?([_, %{"closed" => true}], raise_event_spans(&1))))

        refute automatic["closed"]
        assert automatic["error"] == nil
        assert helper["error"]["name"] == "RuntimeError"
      end
    end

    defp raise_event_spans(spans) do
      Enum.filter(
        spans,
        &(&1["attributes"]["event"] == "raise" or
            &1["name"] == "AppsignalTest.Phoenix.ManualLive#handle_event")
      )
    end
  end
end
