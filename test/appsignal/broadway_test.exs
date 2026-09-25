defmodule Appsignal.BroadwayTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}
  import AppsignalTest.Utils, only: [with_config: 2]

  @events [
    [:broadway, :processor, :start],
    [:broadway, :processor, :stop],
    [:broadway, :processor, :message, :start],
    [:broadway, :processor, :message, :stop],
    [:broadway, :processor, :message, :exception]
  ]

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)

    :ok
  end

  test "attaches to Broadway events automatically" do
    for event <- @events do
      assert attached?(event)
    end
  end

  describe "when :instrument_broadway is set to false" do
    setup do
      for event <- @events do
        :telemetry.detach({Appsignal.Broadway, event})
      end

      with_config(%{instrument_broadway: false}, fn -> Appsignal.start([], []) end)

      on_exit(fn ->
        [:ok, :ok, :ok, :ok, :ok] = Appsignal.Broadway.attach()
      end)
    end

    test "does not attach to Broadway events" do
      for event <- @events do
        assert !attached?(event)
      end
    end
  end

  describe "broadway_processor_start/4" do
    setup do
      execute_processor_start()
    end

    test "creates a span" do
      assert {:ok, [{"broadway"}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "MyApp.Producer#prepare_messages"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "processor.broadway")
    end

    test "sets processor attributes as span tags" do
      assert attribute?("message_count", 2)
      assert attribute?("processor", "MyApp.Pipeline.Broadway.Processor_default_0")
      assert attribute?("producer", "MyApp.Producer")
      assert attribute?("topology_name", "MyApp.Pipeline")
    end
  end

  describe "broadway_processor_start/4, with an atom-named pipeline" do
    setup do
      execute_processor_start(%{
        topology_name: :my_pipeline,
        name: :"my_pipeline.Broadway.Processor_default_0"
      })
    end

    test "sets the span's name without an Elixir prefix" do
      assert {:ok, [{%Span{}, "MyApp.Producer#prepare_messages"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the topology name as a span tag" do
      assert attribute?("message_count", 2)
      assert attribute?("processor", "my_pipeline.Broadway.Processor_default_0")
      assert attribute?("producer", "MyApp.Producer")
      assert attribute?("topology_name", ":my_pipeline")
    end
  end

  describe "broadway_processor_stop/4" do
    setup do
      execute_processor_start()
      span = Tracer.current_span()

      execute_processor_stop()

      [span: span]
    end

    test "sets the message counts as span tags" do
      assert attribute?("failed_messages", 1)
      assert attribute?("successful_messages_to_ack", 2)
      assert attribute?("successful_messages_to_forward", 3)
    end

    test "closes the span", %{span: span} do
      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "broadway_processor_message_start/4" do
    setup do
      execute_message_start()
    end

    test "creates a span" do
      assert {:ok, [{"broadway"}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "MyApp.Producer#handle_message"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "processor_message.broadway")
      assert attribute?("topology_name", "MyApp.Pipeline")
      assert attribute?("producer", "MyApp.Producer")
      assert attribute?("processor", "MyApp.Pipeline.Broadway.Processor_default_0")

      assert attribute?(
               "message",
               "%Appsignal.BroadwayTest.BroadwayMessage{acknowledger: nil, batch_key: :default, batch_mode: :bulk, batcher: :default, data: nil, metadata: %{}, status: :ok}"
             )
    end
  end

  describe "broadway_processor_message_start/4, with an atom-named pipeline" do
    setup do
      execute_message_start(%{
        topology_name: :my_pipeline,
        name: :"my_pipeline.Broadway.Processor_default_0"
      })
    end

    test "sets the span's name without an Elixir prefix" do
      assert {:ok, [{%Span{}, "MyApp.Producer#handle_message"}]} =
               Test.Span.get(:set_name)
    end
  end

  describe "broadway_processor_message_stop/4" do
    setup do
      execute_message_start()
      span = Tracer.current_span()

      execute_message_stop()

      [span: span]
    end

    test "closes the span", %{span: span} do
      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "broadway_processor_message_exception/4" do
    setup do
      execute_message_start()
      span = Tracer.current_span()

      execute_message_exception()

      [span: span]
    end

    test "adds the error to the span" do
      assert {
               :ok,
               [
                 {%Appsignal.Span{reference: _}, :error, %RuntimeError{message: "Exception!"},
                  stacktrace}
               ]
             } =
               Test.Span.get(:add_error)

      assert is_list(stacktrace)
    end

    test "closes the span", %{span: span} do
      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end
  end

  defp attribute?(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} -> id == {Appsignal.Broadway, event} end)
  end

  defp execute_processor_start(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:broadway, :processor, :start],
      %{system_time: 123_456_000},
      Map.merge(sample_processor_metadata(), additional_metadata)
    )
  end

  defp execute_processor_stop(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:broadway, :processor, :stop],
      %{duration: System.convert_time_unit(123, :millisecond, :native)},
      Map.merge(sample_processor_stop_metadata(), additional_metadata)
    )
  end

  defp execute_message_start(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:broadway, :processor, :message, :start],
      %{system_time: 123_456_000},
      Map.merge(sample_message_metadata(), additional_metadata)
    )
  end

  defp execute_message_stop(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:broadway, :processor, :message, :stop],
      %{duration: 123_456_000},
      Map.merge(sample_message_metadata(), additional_metadata)
    )
  end

  defp execute_message_exception(additional_metadata \\ %{}) do
    try do
      raise "Exception!"
    catch
      kind, reason ->
        metadata =
          Map.merge(sample_message_metadata(), %{
            kind: kind,
            reason: reason,
            stacktrace: __STACKTRACE__
          })

        :telemetry.execute(
          [:broadway, :processor, :message, :exception],
          %{duration: 123_456_000},
          Map.merge(metadata, additional_metadata)
        )
    end
  end

  defp sample_processor_metadata do
    %{
      topology_name: MyApp.Pipeline,
      name: :"Elixir.MyApp.Pipeline.Broadway.Processor_default_0",
      processor_key: :default,
      messages: sample_messages(2),
      telemetry_span_context: make_ref(),
      producer: {MyApp.Producer, []}
    }
  end

  defp sample_processor_stop_metadata do
    sample_processor_metadata()
    |> Map.delete(:messages)
    |> Map.merge(%{
      failed_messages: sample_messages(1),
      successful_messages_to_ack: sample_messages(2),
      successful_messages_to_forward: sample_messages(3)
    })
  end

  defp sample_message_metadata do
    %{
      topology_name: MyApp.Pipeline,
      name: :"Elixir.MyApp.Pipeline.Broadway.Processor_default_0",
      processor_key: :default,
      message: sample_message(),
      producer: {MyApp.Producer, []}
    }
  end

  defp sample_message(opts \\ []) do
    Appsignal.BroadwayTest.BroadwayMessage.new(opts)
  end

  defp sample_messages(count) do
    Enum.map(1..count, fn _ -> sample_message() end)
  end
end

# A struct that emulates the `Broadway.Message` struct:
# https://github.com/dashbitco/broadway/blob/v1.3.0/lib/broadway/message.ex
defmodule Appsignal.BroadwayTest.BroadwayMessage do
  @moduledoc false

  defstruct acknowledger: nil,
            batch_key: :default,
            batch_mode: :bulk,
            batcher: :default,
            data: nil,
            metadata: %{},
            status: :ok

  # A subset of `Broadway.Message`'s typing:
  # https://hexdocs.pm/broadway/Broadway.Message.html#t:t/0
  @type t :: %__MODULE__{
          acknowledger: term(),
          batch_key: term(),
          batch_mode: :bulk | :flush,
          batcher: atom(),
          data: term(),
          metadata: map(),
          status: :ok | {:failed, binary()} | {atom(), term(), Exception.stacktrace()}
        }

  @doc false
  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
