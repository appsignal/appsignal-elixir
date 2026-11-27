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

  describe "attach/2" do
    setup do
      :ok =
        :telemetry.attach(
          {__MODULE__, :failures},
          [:appsignal, :handler, :failure],
          &__MODULE__.send_failure/4,
          self()
        )

      on_exit(fn ->
        :telemetry.detach({__MODULE__, :failures})
        :telemetry.detach({__MODULE__, [:appsignal_test, :event]})
      end)
    end

    test "calls the handler with the event" do
      Telemetry.attach(__MODULE__, %{[:appsignal_test, :event] => &__MODULE__.handle/4})
      :telemetry.execute([:appsignal_test, :event], %{count: 1}, %{pid: self()})

      assert_received {:handled, [:appsignal_test, :event], %{count: 1}}
    end

    test "keeps a handler that raises attached, and sends its failure" do
      Telemetry.attach(__MODULE__, %{[:appsignal_test, :event] => &__MODULE__.handle/4})
      :telemetry.execute([:appsignal_test, :event], %{}, %{pid: self(), raise: true})

      assert_received {:failure,
                       %{
                         handler_id: {__MODULE__, [:appsignal_test, :event]},
                         event_name: [:appsignal_test, :event],
                         kind: :error,
                         reason: %RuntimeError{message: "Handler!"},
                         stacktrace: [_ | _]
                       }}

      :telemetry.execute([:appsignal_test, :event], %{count: 2}, %{pid: self()})
      assert_received {:handled, [:appsignal_test, :event], %{count: 2}}
    end
  end

  def handle(_event, _measurements, %{raise: true}, _config), do: raise("Handler!")

  def handle(event, measurements, %{pid: pid}, :ok) do
    send(pid, {:handled, event, measurements})
  end

  def send_failure(_event, _measurements, metadata, pid), do: send(pid, {:failure, metadata})
end
