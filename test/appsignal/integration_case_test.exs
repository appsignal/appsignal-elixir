defmodule AppsignalTest.IntegrationCaseTest do
  use AppsignalTest.IntegrationCase
  alias AppsignalTest.IntegrationCase

  describe "spans/0" do
    test "returns the spans created, with their parents" do
      Appsignal.instrument("root", fn ->
        Appsignal.instrument("child", fn -> :ok end)
      end)

      assert [
               %{"name" => "root", "parent_span_id" => "", "closed" => true} = root,
               %{"name" => "child", "closed" => true} = child
             ] = spans()

      assert child["parent_span_id"] == root["span_id"]
    end

    test "returns spans created in other processes" do
      Task.await(Task.async(fn -> Appsignal.instrument("task", fn -> :ok end) end))

      assert [%{"name" => "task", "closed" => true}] = spans()
    end

    @tag leaves_spans_open: "the span is left open to be read"
    test "returns open spans" do
      span = Appsignal.Tracer.create_span("background_job")
      Appsignal.Span.set_name(span, "open")

      assert [%{"name" => "open"} = open] = spans()
      refute open["closed"]
      assert [^open] = open_spans()
    end
  end

  describe "await_spans/1" do
    test "waits for a span closed in another process" do
      spawn(fn -> Appsignal.instrument("later", fn -> Process.sleep(50) end) end)

      assert [%{"name" => "later", "closed" => true}] =
               await_spans(&match?([%{"closed" => true}], &1))
    end
  end

  describe "check/4" do
    test "passes when nothing went wrong" do
      assert :ok = IntegrationCase.check([], [], [], %{})
    end

    test "fails when a handler raised" do
      assert_raise ExUnit.AssertionError, ~r/A :telemetry handler raised/, fn ->
        IntegrationCase.check([%{handler_id: :handler}], [], [], %{})
      end
    end

    test "fails when a span is left open" do
      assert_raise ExUnit.AssertionError, ~r/Spans left open/, fn ->
        IntegrationCase.check([], [%{"name" => "open"}], [], %{})
      end
    end

    test "passes when a test tagged leaves_spans_open leaves a span open" do
      assert :ok =
               IntegrationCase.check([], [%{"name" => "open"}], [], %{leaves_spans_open: "why"})
    end

    test "fails when a test tagged leaves_spans_open leaves no span open" do
      assert_raise ExUnit.AssertionError,
                   ~r/tagged leaves_spans_open, but left no span open/,
                   fn ->
                     IntegrationCase.check([], [], [], %{leaves_spans_open: "why"})
                   end
    end

    test "fails when an AppSignal handler was detached" do
      assert_raise ExUnit.AssertionError, ~r/AppSignal :telemetry handlers detached/, fn ->
        IntegrationCase.check([], [], [{Appsignal.Ecto, [:repo, :query]}], %{})
      end
    end

    test "passes when a test tagged detaches_handlers detaches a handler" do
      detached = [{Appsignal.Ecto, [:repo, :query]}]
      assert :ok = IntegrationCase.check([], [], detached, %{detaches_handlers: true})
    end

    test "fails when a test tagged detaches_handlers detaches no handler" do
      assert_raise ExUnit.AssertionError,
                   ~r/tagged detaches_handlers, but detached no handler/,
                   fn ->
                     IntegrationCase.check([], [], [], %{detaches_handlers: true})
                   end
    end
  end
end
