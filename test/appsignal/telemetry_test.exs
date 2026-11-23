defmodule Appsignal.TelemetryTest do
  use ExUnit.Case
  alias Appsignal.{Telemetry, Test, Tracer}

  setup do
    start_supervised(Test.Nif)
    start_supervised(Test.Tracer)
    start_supervised(Test.Monitor)
    :ok
  end

  describe "with a telemetry_span_context" do
    test "closes the span kept for the event's context" do
      first = Tracer.create_span("http_request")
      second = Tracer.create_span("http_request", first)
      Telemetry.put_span(:handler, %{telemetry_span_context: :first}, first)
      Telemetry.put_span(:handler, %{telemetry_span_context: :second}, second)

      Telemetry.close_span(:handler, %{telemetry_span_context: :first})

      assert Test.Tracer.get!(:close_span) == [{first}]
      assert Telemetry.get_span(:handler, %{telemetry_span_context: :first}) == nil
      assert Telemetry.get_span(:handler, %{telemetry_span_context: :second}) == second
    end

    test "closes nothing for a context with no span kept" do
      span = Tracer.create_span("http_request")
      Telemetry.put_span(:handler, %{telemetry_span_context: :first}, span)

      assert Telemetry.close_span(:handler, %{telemetry_span_context: :other}) == nil
      assert Test.Tracer.get(:close_span) == :error
    end
  end

  describe "without a telemetry_span_context" do
    test "closes the span kept last" do
      outer = Tracer.create_span("http_request")
      inner = Tracer.create_span("http_request", outer)
      Telemetry.put_span(:handler, %{}, outer)
      Telemetry.put_span(:handler, %{}, inner)

      Telemetry.close_span(:handler, %{})
      assert Test.Tracer.get!(:close_span) == [{inner}]
      assert Telemetry.get_span(:handler, %{}) == outer

      Telemetry.close_span(:handler, %{})
      assert Test.Tracer.get!(:close_span) == [{outer}, {inner}]
      assert Telemetry.get_span(:handler, %{}) == nil
    end

    test "closes nothing for an event whose start kept no span" do
      outer = Tracer.create_span("http_request")
      Telemetry.put_span(:handler, %{}, outer)
      Telemetry.put_span(:handler, %{}, nil)

      assert Telemetry.close_span(:handler, %{}) == nil
      assert Test.Tracer.get(:close_span) == :error
      assert Telemetry.get_span(:handler, %{}) == outer
    end

    test "keeps each handler's spans apart" do
      span = Tracer.create_span("http_request")
      Telemetry.put_span(:handler, %{}, span)

      assert Telemetry.close_span(:other_handler, %{}) == nil
      assert Telemetry.get_span(:handler, %{}) == span
    end
  end

  test "takes a kept span without closing it" do
    span = Tracer.create_span("http_request")
    Telemetry.put_span(:handler, %{telemetry_span_context: :first}, span)

    assert Telemetry.take_span(:handler, %{telemetry_span_context: :first}) == span
    assert Telemetry.get_span(:handler, %{telemetry_span_context: :first}) == nil
    assert Test.Tracer.get(:close_span) == :error
  end

  test "closes a kept span and the spans left open under it" do
    span = Tracer.create_span("http_request")
    Telemetry.put_span(:handler, %{}, span)
    _left_open = Tracer.create_span("http_request", span)

    Telemetry.close_span(:handler, %{})

    assert Test.Tracer.get!(:close_span) == [{span}]
    assert Tracer.lookup(self()) == []
  end
end
