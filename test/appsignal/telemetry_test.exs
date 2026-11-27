defmodule Appsignal.TelemetryTest do
  use ExUnit.Case, async: true
  alias Appsignal.Telemetry

  describe "correlated spans" do
    test "are taken by their context" do
      Telemetry.put_correlated_span(:handler, :first, :first_span)
      Telemetry.put_correlated_span(:handler, :second, :second_span)

      assert Telemetry.take_correlated_span(:handler, :first) == :first_span
      assert Telemetry.get_correlated_span(:handler, :first) == nil
      assert Telemetry.get_correlated_span(:handler, :second) == :second_span
    end

    test "are nil for a context with no span kept" do
      Telemetry.put_correlated_span(:handler, :first, :span)

      assert Telemetry.take_correlated_span(:handler, :other) == nil
      assert Telemetry.get_correlated_span(:handler, :first) == :span
    end
  end

  describe "stacked spans" do
    test "are taken last in, first out" do
      Telemetry.put_stacked_span(:handler, :outer)
      Telemetry.put_stacked_span(:handler, :inner)

      assert Telemetry.get_stacked_span(:handler) == :inner
      assert Telemetry.take_stacked_span(:handler) == :inner
      assert Telemetry.take_stacked_span(:handler) == :outer
      assert Telemetry.take_stacked_span(:handler) == nil
    end

    test "keep a start that kept no span, so that its stop takes nothing" do
      Telemetry.put_stacked_span(:handler, :outer)
      Telemetry.put_stacked_span(:handler, nil)

      assert Telemetry.take_stacked_span(:handler) == nil
      assert Telemetry.get_stacked_span(:handler) == :outer
    end
  end

  test "keeps each handler's spans apart" do
    Telemetry.put_stacked_span(:handler, :span)
    Telemetry.put_correlated_span(:handler, :context, :correlated)

    assert Telemetry.take_stacked_span(:other_handler) == nil
    assert Telemetry.take_correlated_span(:other_handler, :context) == nil
    assert Telemetry.get_stacked_span(:handler) == :span
  end

  describe "spans kept for an event" do
    test "are correlated by the event's telemetry_span_context" do
      Telemetry.put_span(:handler, %{telemetry_span_context: :context}, :span)

      assert Telemetry.get_correlated_span(:handler, :context) == :span
      assert Telemetry.get_span(:handler, %{telemetry_span_context: :context}) == :span
      assert Telemetry.take_span(:handler, %{telemetry_span_context: :context}) == :span
      assert Telemetry.get_span(:handler, %{telemetry_span_context: :context}) == nil
    end

    test "are stacked for an event without one" do
      Telemetry.put_span(:handler, %{}, :span)

      assert Telemetry.get_stacked_span(:handler) == :span
      assert Telemetry.get_span(:handler, %{}) == :span
      assert Telemetry.take_span(:handler, %{}) == :span
      assert Telemetry.get_span(:handler, %{}) == nil
    end
  end
end
