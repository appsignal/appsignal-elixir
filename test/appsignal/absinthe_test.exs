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
    test "creates a span" do
      execute_operation_start(%{options: [operation_name: "OperationName"]})
      assert {:ok, [{"graphql", nil}]} = Test.Tracer.get(:create_span)
    end

    test "it updates the root span's namespace" do
      execute_operation_start()
      root_span = Appsignal.Tracer.root_span()

      assert {:ok, [{^root_span, "graphql"}]} =
               Test.Span.get(:set_namespace_if_nil)
    end

    test "without operation name it sets the span's name to graphql" do
      execute_operation_start(%{options: []})
      assert {:ok, [{%Span{}, "graphql"}]} = Test.Span.get(:set_name)
    end

    test "without operation name it doesn't update the root span's name and namespace" do
      execute_operation_start(%{options: []})
      assert :error = Test.Span.get(:set_name_if_nil)
      assert :error = Test.Span.get(:set_namespace)
    end

    test "with operation name it sets the span's name to the operation name" do
      execute_operation_start(%{options: [operation_name: "OperationName"]})
      assert {:ok, [{%Span{}, "OperationName"}]} = Test.Span.get(:set_name)
    end

    test "it updates the root span's name" do
      execute_operation_start(%{options: [operation_name: "OperationName"]})
      root_span = Appsignal.Tracer.root_span()
      assert {:ok, [{^root_span, "OperationName"}]} = Test.Span.get(:set_name_if_nil)
    end

    test "sets the span's category" do
      execute_operation_start(%{options: []})
      assert attribute?("appsignal:category", "call.graphql")
    end

    test "does not detach the handler" do
      execute_operation_start(%{options: []})
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
      additional_metadata
    )
  end

  defp execute_operation_stop(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:absinthe, :execute, :operation, :stop],
      %{duration: 123 * 1_000_000},
      additional_metadata
    )
  end
end
