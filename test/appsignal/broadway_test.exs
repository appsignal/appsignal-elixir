if Appsignal.Dependencies.present?(:broadway) do
  defmodule AppsignalTest.BroadwayPipeline do
    @moduledoc false
    use Broadway
    alias Broadway.Message

    def start_link(opts), do: start_link(__MODULE__, opts)

    @doc false
    def start_link(module, opts) do
      batchers =
        if opts[:batchers],
          do: [default: [batch_size: 2, batch_timeout: 50]],
          else: []

      Broadway.start_link(module,
        name: Keyword.get(opts, :name, module),
        producer: [module: {Broadway.DummyProducer, []}],
        processors: [default: [concurrency: Keyword.get(opts, :concurrency, 1), max_demand: 1]],
        batchers: batchers
      )
    end

    @impl Broadway
    def prepare_messages(messages, _context) do
      data = Enum.map(messages, & &1.data)

      cond do
        "raise in prepare" in data ->
          raise "Prepare exception!"

        "instrument in prepare" in data ->
          Appsignal.instrument("Prepare messages", "prepare.messages", fn -> messages end)

        true ->
          messages
      end
    end

    @impl Broadway
    def handle_message(_processor, %Message{data: data} = message, _context) do
      case data do
        "fail" ->
          Message.failed(message, "Failed!")

        "raise" ->
          raise "Exception!"

        "instrument" ->
          Appsignal.instrument("Handle message", "handle.message", fn -> message end)

        "slow" ->
          Process.sleep(20)
          message

        _ ->
          message
      end
    end

    @impl Broadway
    def handle_batch(_batcher, messages, _batch_info, _context) do
      if Enum.any?(messages, &(&1.data == "fail batch")) do
        raise "Batch exception!"
      end

      messages
    end
  end

  defmodule AppsignalTest.BroadwayRegisteredPipeline do
    @moduledoc false
    use Broadway

    def start_link(opts), do: AppsignalTest.BroadwayPipeline.start_link(__MODULE__, opts)

    # Broadway builds its processes' names from an atom pipeline name only, so
    # a pipeline registered under a `{:via, module, term}` name names them.
    @impl Broadway
    def process_name({:via, Registry, {registry, key}}, base_name) do
      {:via, Registry, {registry, {key, base_name}}}
    end

    @impl Broadway
    defdelegate handle_message(processor, message, context), to: AppsignalTest.BroadwayPipeline
  end

  defmodule Appsignal.BroadwayTest do
    use AppsignalTest.IntegrationCase
    import AppsignalTest.Utils, only: [with_config: 2]
    alias AppsignalTest.BroadwayPipeline
    alias Broadway.Message

    @pipeline "AppsignalTest.BroadwayPipeline"
    @processor "AppsignalTest.BroadwayPipeline.Broadway.Processor_default_0"

    setup context do
      case Map.get(context, :pipeline, []) do
        false -> :ok
        opts -> start_supervised!({BroadwayPipeline, opts})
      end

      :ok
    end

    describe "processing messages through Broadway" do
      test "acknowledges a successful message" do
        assert {[%Message{data: %{"id" => 1}}], []} = process(%{"id" => 1})
      end

      test "fails a message marked as failed" do
        assert {[], [%Message{status: {:failed, "Failed!"}}]} = process("fail")
      end

      @tag :capture_log
      test "fails a message whose handle_message/3 raises" do
        assert {[], [%Message{status: {:error, %RuntimeError{message: "Exception!"}, _}}]} =
                 process("raise")
      end

      @tag :capture_log
      test "keeps processing messages after handle_message/3 raises" do
        process("raise")
        assert {[%Message{data: "data"}], []} = process("data")
      end

      @tag :capture_log
      test "fails the message when prepare_messages/2 raises" do
        assert {[], [%Message{status: {:error, %RuntimeError{message: "Prepare exception!"}, _}}]} =
                 process("raise in prepare")
      end

      @tag pipeline: [batchers: true]
      test "acknowledges a batch's messages" do
        assert {[_, _], []} = process_batch(["one", "two"])
      end

      @tag :capture_log
      @tag pipeline: [batchers: true]
      test "fails a batch's messages when handle_batch/4 raises" do
        assert {[],
                [
                  %Message{status: {:error, %RuntimeError{}, _}},
                  %Message{status: {:error, %RuntimeError{}, _}}
                ]} = process_batch(["one", "fail batch"])
      end
    end

    describe "the processor's span" do
      test "is a root span with the processor's attributes" do
        process(%{"id" => 1})

        assert [span] = named(closed_spans(2), "#{@pipeline}#prepare_messages")
        assert span["parent_span_id"] == ""
        assert span["namespace"] == "broadway"
        assert category(span) == "processor.broadway"
        assert span["error"] == nil

        assert Map.delete(span["attributes"], "appsignal:category") == %{
                 "message_count" => 1,
                 "processor" => @processor,
                 "producer" => "Broadway.DummyProducer",
                 "topology_name" => @pipeline,
                 "failed_messages" => 0,
                 "successful_messages_to_ack" => 1,
                 "successful_messages_to_forward" => 0
               }
      end

      test "counts a message marked as failed, without an error" do
        process("fail")

        assert [span] = named(closed_spans(2), "#{@pipeline}#prepare_messages")
        assert span["error"] == nil
        assert span["attributes"]["failed_messages"] == 1
        assert span["attributes"]["successful_messages_to_ack"] == 0
      end

      @tag :capture_log
      test "counts a message whose handle_message/3 raises as failed, without an error" do
        process("raise")

        assert [span] = named(closed_spans(2), "#{@pipeline}#prepare_messages")
        assert span["error"] == nil
        assert span["attributes"]["failed_messages"] == 1
      end

      @tag :capture_log
      test "counts the message as failed, without an error, when prepare_messages/2 raises" do
        process("raise in prepare")

        assert [span] = closed_spans(1)
        assert span["name"] == "#{@pipeline}#prepare_messages"
        assert span["error"] == nil
        assert span["attributes"]["failed_messages"] == 1
      end

      test "has a span instrumented in prepare_messages/2 as its child" do
        process("instrument in prepare")
        spans = closed_spans(3)

        [processor] = named(spans, "#{@pipeline}#prepare_messages")
        assert [%{"name" => "Prepare messages"} = child] = children(spans, processor)
        assert category(child) == "prepare.messages"
      end

      @tag pipeline: [batchers: true]
      test "counts the messages it forwards to a batcher" do
        process_batch(["one", "two"])

        processors = named(closed_spans(4), "#{@pipeline}#prepare_messages")
        assert length(processors) == 2

        for processor <- processors do
          assert processor["attributes"]["successful_messages_to_forward"] == 1
          assert processor["attributes"]["successful_messages_to_ack"] == 0
        end
      end

      @tag :capture_log
      @tag pipeline: [batchers: true]
      test "has no error when handle_batch/4 raises" do
        process_batch(["one", "fail batch"])

        processors = named(closed_spans(4), "#{@pipeline}#prepare_messages")
        assert [%{"error" => nil}, %{"error" => nil}] = processors
      end

      @tag pipeline: [concurrency: 4]
      test "counts every message, across concurrent processors" do
        process_slow_messages(8)

        processors = named(closed_messages(8), "#{@pipeline}#prepare_messages")
        assert Enum.sum(Enum.map(processors, & &1["attributes"]["message_count"])) == 8
      end
    end

    describe "the message's span" do
      test "is a root span of its own trace, with the processor's attributes" do
        process(%{"id" => 1})
        spans = closed_spans(2)

        [processor] = named(spans, "#{@pipeline}#prepare_messages")
        assert [span] = named(spans, "#{@pipeline}#handle_message")
        assert span["parent_span_id"] == ""
        assert span["trace_id"] != processor["trace_id"]
        assert span["namespace"] == "broadway"
        assert category(span) == "processor_message.broadway"
        assert span["error"] == nil

        assert Map.delete(span["attributes"], "appsignal:category") == %{
                 "processor" => @processor,
                 "producer" => "Broadway.DummyProducer",
                 "topology_name" => @pipeline
               }
      end

      test "has the whole message as params" do
        process(%{"id" => 1}, metadata: %{queue: "q"})

        [span] = named(closed_spans(2), "#{@pipeline}#handle_message")

        assert %{
                 "acknowledger" => ["Elixir.Broadway.CallerAcknowledger", [pid, ref], "ok"],
                 "batch_key" => "default",
                 "batch_mode" => "flush",
                 "batcher" => "default",
                 "data" => %{"id" => 1},
                 "metadata" => %{"queue" => "q"},
                 "status" => "ok"
               } = span["sample_data"]["params"]

        assert pid == inspect(self())
        assert ref =~ "#Reference<"
      end

      test "has no params when send_params is false" do
        with_config(%{send_params: false}, fn ->
          process("data")

          assert [span] = named(closed_spans(2), "#{@pipeline}#handle_message")
          refute Map.has_key?(span["sample_data"], "params")
        end)
      end

      test "has no error for a message marked as failed" do
        process("fail")

        assert [span] = named(closed_spans(2), "#{@pipeline}#handle_message")
        assert span["error"] == nil
      end

      @tag :capture_log
      test "has the error when handle_message/3 raises" do
        process("raise")

        assert [span] = named(closed_spans(2), "#{@pipeline}#handle_message")

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Exception!"} =
                 span["error"]

        assert [line | _] = Jason.decode!(span["error"]["backtrace_json"])
        assert line =~ "AppsignalTest.BroadwayPipeline.handle_message/3"
      end

      test "has a span instrumented in handle_message/3 as its child" do
        process("instrument")
        spans = closed_spans(3)

        [message] = named(spans, "#{@pipeline}#handle_message")
        assert [%{"name" => "Handle message"} = child] = children(spans, message)
        assert category(child) == "handle.message"
      end

      @tag :capture_log
      @tag pipeline: [batchers: true]
      test "has no error when handle_batch/4 raises" do
        process_batch(["one", "fail batch"])

        messages = named(closed_spans(4), "#{@pipeline}#handle_message")
        assert [%{"error" => nil}, %{"error" => nil}] = messages
      end

      @tag pipeline: [concurrency: 4]
      test "names the processor that handled it, across concurrent processors" do
        process_slow_messages(8)

        messages = named(closed_messages(8), "#{@pipeline}#handle_message")
        names = messages |> Enum.map(& &1["attributes"]["processor"]) |> Enum.uniq()
        assert length(names) > 1

        for name <- names do
          assert name =~ ~r/^AppsignalTest\.BroadwayPipeline\.Broadway\.Processor_default_[0-3]$/
        end
      end
    end

    describe "naming the spans after the pipeline" do
      @tag pipeline: [name: :appsignal_broadway_test]
      test "named with an atom" do
        process("data", to: :appsignal_broadway_test)
        spans = closed_spans(2)

        assert [processor] = named(spans, ":appsignal_broadway_test#prepare_messages")
        assert [message] = named(spans, ":appsignal_broadway_test#handle_message")

        for span <- [processor, message] do
          assert span["attributes"]["topology_name"] == ":appsignal_broadway_test"

          assert span["attributes"]["processor"] ==
                   "appsignal_broadway_test.Broadway.Processor_default_0"
        end
      end

      if Appsignal.Dependencies.match?(:broadway, ">= 1.1.0") do
        @tag pipeline: false
        test "registered under a via tuple" do
          start_supervised!({Registry, keys: :unique, name: AppsignalTest.BroadwayRegistry})
          name = {:via, Registry, {AppsignalTest.BroadwayRegistry, :registered}}
          start_supervised!({AppsignalTest.BroadwayRegisteredPipeline, name: name})
          process("data", to: name)
          spans = closed_spans(2)

          assert [processor] = named(spans, ":registered#prepare_messages")
          assert [message] = named(spans, ":registered#handle_message")

          for span <- [processor, message] do
            assert span["attributes"]["topology_name"] == ":registered"
            assert span["attributes"]["processor"] == "Processor_default_0"
          end
        end
      end
    end

    describe "work that records no span" do
      @tag pipeline: [batchers: true]
      test "handling a batch in handle_batch/4" do
        process_batch(["one", "two"])

        names = Enum.map(closed_spans(4), & &1["name"])

        assert Enum.frequencies(names) == %{
                 "#{@pipeline}#prepare_messages" => 2,
                 "#{@pipeline}#handle_message" => 2
               }
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to Broadway's processor and message events" do
        for event <- events() do
          assert {Appsignal.Broadway, event} in handler_ids()
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_broadway set to false" do
      @describetag :detaches_handlers

      setup do
        for {Appsignal.Broadway, _event} = id <- handler_ids() do
          :telemetry.detach(id)
        end

        with_config(%{instrument_broadway: false}, fn -> Appsignal.start([], []) end)
        :ok
      end

      test "does not attach to Broadway's processor and message events" do
        refute Enum.any?(handler_ids(), &match?({Appsignal.Broadway, _}, &1))
      end

      test "records no span for a message" do
        process("data")
        assert spans() == []
      end
    end

    defp process(data, opts \\ []) do
      {pipeline, opts} = Keyword.pop(opts, :to, BroadwayPipeline)
      ref = Broadway.test_message(pipeline, data, opts)
      assert_receive {:ack, ^ref, successful, failed}
      {successful, failed}
    end

    defp process_batch(data) do
      ref = Broadway.test_batch(BroadwayPipeline, data)
      assert_receive {:ack, ^ref, successful, failed}
      {successful, failed}
    end

    defp process_slow_messages(count) do
      ref = Broadway.test_batch(BroadwayPipeline, List.duplicate("slow", count))
      assert receive_acked(ref, count) == count
    end

    defp receive_acked(ref, expected, acked \\ 0)
    defp receive_acked(_ref, expected, acked) when acked >= expected, do: acked

    defp receive_acked(ref, expected, acked) do
      assert_receive {:ack, ^ref, successful, []}
      receive_acked(ref, expected, acked + length(successful))
    end

    defp closed_spans(count) do
      await_spans(&(length(&1) == count and all_closed?(&1)))
    end

    defp closed_messages(count) do
      await_spans(
        &(length(named(&1, "#{@pipeline}#handle_message")) == count and all_closed?(&1))
      )
    end

    defp events do
      [
        [:broadway, :processor, :start],
        [:broadway, :processor, :stop],
        [:broadway, :processor, :message, :start],
        [:broadway, :processor, :message, :stop],
        [:broadway, :processor, :message, :exception]
      ]
    end

    defp handler_ids, do: Enum.map(:telemetry.list_handlers([]), & &1.id)
  end
end

defmodule Appsignal.Broadway.MetadataTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)

    :ok
  end

  describe "events without producer metadata" do
    test "set no producer attribute on the processor's span, as before Broadway 1.0.4" do
      metadata = Map.delete(metadata(), :producer)
      Appsignal.Broadway.broadway_processor_start([], %{}, metadata, :ok)

      {:ok, attributes} = Test.Span.get(:set_attribute)
      assert Enum.any?(attributes, &match?({%Span{}, "topology_name", "MyApp.Pipeline"}, &1))
      refute Enum.any?(attributes, &match?({%Span{}, "producer", _}, &1))
    end

    test "set no producer attribute on the message's span, as before Broadway 1.3" do
      metadata = metadata() |> Map.delete(:producer) |> Map.put(:message, %{data: "data"})
      Appsignal.Broadway.broadway_processor_message_start([], %{}, metadata, :ok)

      {:ok, attributes} = Test.Span.get(:set_attribute)
      assert Enum.any?(attributes, &match?({%Span{}, "topology_name", "MyApp.Pipeline"}, &1))
      refute Enum.any?(attributes, &match?({%Span{}, "producer", _}, &1))
    end
  end

  defp metadata do
    %{
      topology_name: MyApp.Pipeline,
      name: :"MyApp.Pipeline.Broadway.Processor_default_0",
      messages: [],
      producer: {MyApp.Producer, []}
    }
  end
end
