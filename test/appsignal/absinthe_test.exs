defmodule Appsignal.AbsintheTest do
  use ExUnit.Case
  alias Appsignal.{FakeAppsignal, Span, Test, Tracer}
  import AppsignalTest.Utils, only: [with_config: 2]

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)

    :ok
  end

  test "attaches to Absinthe events automatically" do
    assert attached?([:absinthe, :execute, :operation, :start])
    assert attached?([:absinthe, :execute, :operation, :stop])
  end

  describe "when :instrument_absinthe is set to false" do
    setup do
      :telemetry.detach({Appsignal.Absinthe, [:absinthe, :execute, :operation, :start]})
      :telemetry.detach({Appsignal.Absinthe, [:absinthe, :execute, :operation, :stop]})

      with_config(%{instrument_absinthe: false}, fn -> Appsignal.start([], []) end)

      on_exit(fn ->
        [:ok, :ok] = Appsignal.Absinthe.attach()
      end)
    end

    test "does not attach to Absinthe events" do
      assert !attached?([:absinthe, :execute, :operation, :start])
      assert !attached?([:absinthe, :execute, :operation, :stop])
    end
  end

  describe "absinthe_execute_operation_start/4" do
    setup do
      execute_operation_start()
    end

    test "creates a span" do
      assert {:ok, [{"http_request", nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "graphql"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "call.graphql")
    end

    test "does not detach the handler" do
      assert attached?([:absinthe, :execute, :operation, :start])
    end
  end

  describe "execute_operation_stop/4" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_operation_start()
      span = Tracer.current_span()
      execute_operation_stop()

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "does not detach the handler" do
      assert attached?([:absinthe, :execute, :operation, :stop])
    end
  end

  defp attribute?(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end

  defp has_attribute?(asserted_key) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, _data} ->
      key == asserted_key
    end)
  end

  defp attached?(event, function \\ nil) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      case function do
        nil -> true
        f -> function == f
      end && id == {Appsignal.Absinthe, event}
    end)
  end

  defp execute_operation_start(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:absinthe, :execute, :operation, :start],
      %{},
      %{}
    )
  end

  defp execute_operation_stop(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:absinthe, :execute, :operation, :stop],
      %{duration: 123 * 1_000_000},
      %{}
    )
  end
end
