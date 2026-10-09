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

    describe "a successful message" do
      setup do
        start_pipeline()
        ref = Broadway.test_message(BroadwayPipeline, %{"id" => 1}, metadata: %{queue: "q"})
        assert_receive {:ack, ^ref, [%Message{data: %{"id" => 1}}], []}
        [spans: settle(2)]
      end

      test "records a root span for the processor", %{spans: spans} do
        assert [span] = named(spans, "#{@pipeline}#prepare_messages")
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

      test "records the message's span as a root span of its own", %{spans: spans} do
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

      test "records the whole message as the span's params", %{spans: spans} do
        [span] = named(spans, "#{@pipeline}#handle_message")

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
    end

    test "does not record the message as params when send_params is false" do
      start_pipeline()

      with_config(%{send_params: false}, fn ->
        ref = Broadway.test_message(BroadwayPipeline, "data")
        assert_receive {:ack, ^ref, [_], []}
        spans = settle(2)

        assert [span] = named(spans, "#{@pipeline}#handle_message")
        refute Map.has_key?(span["sample_data"], "params")
      end)
    end

    test "records no error for a message marked as failed" do
      start_pipeline()
      ref = Broadway.test_message(BroadwayPipeline, "fail")
      assert_receive {:ack, ^ref, [], [%Message{status: {:failed, "Failed!"}}]}
      spans = settle(2)

      assert [message] = named(spans, "#{@pipeline}#handle_message")
      assert message["error"] == nil

      assert [processor] = named(spans, "#{@pipeline}#prepare_messages")
      assert processor["error"] == nil
      assert processor["attributes"]["failed_messages"] == 1
      assert processor["attributes"]["successful_messages_to_ack"] == 0
    end

    describe "a message whose handle_message/3 raises" do
      @describetag :capture_log

      setup do
        start_pipeline()
        ref = Broadway.test_message(BroadwayPipeline, "raise")

        assert_receive {:ack, ^ref, [],
                        [%Message{status: {:error, %RuntimeError{message: "Exception!"}, _}}]}

        [spans: settle(2)]
      end

      test "records the error on the message's span", %{spans: spans} do
        assert [span] = named(spans, "#{@pipeline}#handle_message")

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Exception!"} =
                 span["error"]

        assert [line | _] = Jason.decode!(span["error"]["backtrace_json"])
        assert line =~ "AppsignalTest.BroadwayPipeline.handle_message/3"
      end

      test "records the message as failed on the processor's span", %{spans: spans} do
        assert [span] = named(spans, "#{@pipeline}#prepare_messages")
        assert span["error"] == nil
        assert span["attributes"]["failed_messages"] == 1
      end

      test "keeps processing messages" do
        ref = Broadway.test_message(BroadwayPipeline, "data")
        assert_receive {:ack, ^ref, [%Message{data: "data"}], []}
        settle(4)
      end
    end

    @tag :capture_log
    test "records no error when prepare_messages/2 raises" do
      start_pipeline()
      ref = Broadway.test_message(BroadwayPipeline, "raise in prepare")

      assert_receive {:ack, ^ref, [],
                      [
                        %Message{
                          status: {:error, %RuntimeError{message: "Prepare exception!"}, _}
                        }
                      ]}

      assert [span] = settle(1)
      assert span["name"] == "#{@pipeline}#prepare_messages"
      assert span["error"] == nil
      assert span["attributes"]["failed_messages"] == 1
    end

    test "records a span instrumented in handle_message/3 as the message span's child" do
      start_pipeline()
      ref = Broadway.test_message(BroadwayPipeline, "instrument")
      assert_receive {:ack, ^ref, [_], []}
      spans = settle(3)

      [message] = named(spans, "#{@pipeline}#handle_message")
      assert [%{"name" => "Handle message"} = child] = children(spans, message)
      assert category(child) == "handle.message"
    end

    test "records a span instrumented in prepare_messages/2 as the processor span's child" do
      start_pipeline()
      ref = Broadway.test_message(BroadwayPipeline, "instrument in prepare")
      assert_receive {:ack, ^ref, [_], []}
      spans = settle(3)

      [processor] = named(spans, "#{@pipeline}#prepare_messages")
      assert [%{"name" => "Prepare messages"} = child] = children(spans, processor)
      assert category(child) == "prepare.messages"
    end

    describe "with a batcher" do
      setup do
        start_pipeline(batchers: true)
      end

      test "records the processor and message spans, and none for the batch" do
        ref = Broadway.test_batch(BroadwayPipeline, ["one", "two"])
        assert_receive {:ack, ^ref, [_, _], []}
        spans = settle(4)

        assert length(named(spans, "#{@pipeline}#handle_message")) == 2
        processors = named(spans, "#{@pipeline}#prepare_messages")
        assert length(processors) == 2

        for processor <- processors do
          assert processor["attributes"]["successful_messages_to_forward"] == 1
          assert processor["attributes"]["successful_messages_to_ack"] == 0
        end
      end

      @tag :capture_log
      test "records no error when handle_batch/4 raises" do
        ref = Broadway.test_batch(BroadwayPipeline, ["one", "fail batch"])

        assert_receive {:ack, ^ref, [],
                        [
                          %Message{status: {:error, %RuntimeError{}, _}},
                          %Message{status: {:error, %RuntimeError{}, _}}
                        ]}

        spans = settle(4)
        assert Enum.all?(spans, &(&1["error"] == nil))
      end
    end

    test "records the spans of messages handled by concurrent processors" do
      start_pipeline(concurrency: 4)
      ref = Broadway.test_batch(BroadwayPipeline, List.duplicate("slow", 8))
      assert receive_acked(ref, 8) == 8
      spans = settle(&(length(named(&1, "#{@pipeline}#handle_message")) == 8))

      messages = named(spans, "#{@pipeline}#handle_message")
      processors = named(spans, "#{@pipeline}#prepare_messages")
      assert Enum.sum(Enum.map(processors, & &1["attributes"]["message_count"])) == 8

      names = messages |> Enum.map(& &1["attributes"]["processor"]) |> Enum.uniq()
      assert length(names) > 1

      for name <- names do
        assert name =~ ~r/^AppsignalTest\.BroadwayPipeline\.Broadway\.Processor_default_[0-3]$/
      end
    end

    test "names the spans after a pipeline named with an atom" do
      start_pipeline(name: :appsignal_broadway_test)
      ref = Broadway.test_message(:appsignal_broadway_test, "data")
      assert_receive {:ack, ^ref, [_], []}
      spans = settle(2)

      assert [processor] = named(spans, ":appsignal_broadway_test#prepare_messages")
      assert [message] = named(spans, ":appsignal_broadway_test#handle_message")

      for span <- [processor, message] do
        assert span["attributes"]["topology_name"] == ":appsignal_broadway_test"

        assert span["attributes"]["processor"] ==
                 "appsignal_broadway_test.Broadway.Processor_default_0"
      end
    end

    if Appsignal.Dependencies.match?(:broadway, ">= 1.1.0") do
      test "names the spans after a pipeline registered under a via tuple" do
        start_supervised!({Registry, keys: :unique, name: AppsignalTest.BroadwayRegistry})
        name = {:via, Registry, {AppsignalTest.BroadwayRegistry, :registered}}
        start_supervised!({AppsignalTest.BroadwayRegisteredPipeline, name: name})
        ref = Broadway.test_message(name, "data")
        assert_receive {:ack, ^ref, [_], []}
        spans = settle(2)

        assert [processor] = named(spans, ":registered#prepare_messages")
        assert [message] = named(spans, ":registered#handle_message")

        for span <- [processor, message] do
          assert span["attributes"]["topology_name"] == ":registered"
          assert span["attributes"]["processor"] == "Processor_default_0"
        end
      end
    end

    describe "when :instrument_broadway is set to false" do
      @describetag :detaches_handlers

      setup do
        for {Appsignal.Broadway, _event} = id <- handler_ids() do
          :telemetry.detach(id)
        end

        with_config(%{instrument_broadway: false}, fn -> Appsignal.start([], []) end)
        :ok
      end

      test "does not attach to Broadway events, and records no spans" do
        refute Enum.any?(handler_ids(), &match?({Appsignal.Broadway, _}, &1))

        start_pipeline()
        ref = Broadway.test_message(BroadwayPipeline, "data")
        assert_receive {:ack, ^ref, [_], []}
        assert spans() == []
      end
    end

    defp start_pipeline(opts \\ []) do
      start_supervised!({BroadwayPipeline, opts})
      :ok
    end

    defp receive_acked(ref, expected, acked \\ 0)
    defp receive_acked(_ref, expected, acked) when acked >= expected, do: acked

    defp receive_acked(ref, expected, acked) do
      assert_receive {:ack, ^ref, successful, []}
      receive_acked(ref, expected, acked + length(successful))
    end

    defp settle(count) when is_integer(count) do
      settle(&(length(&1) == count))
    end

    defp settle(fun) do
      await_spans(&(fun.(&1) and all_closed?(&1)))
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

  test "sets no producer attribute without producer metadata, as before Broadway 1.0.4" do
    metadata = Map.delete(metadata(), :producer)
    Appsignal.Broadway.broadway_processor_start([], %{}, metadata, :ok)

    {:ok, attributes} = Test.Span.get(:set_attribute)
    assert Enum.any?(attributes, &match?({%Span{}, "topology_name", "MyApp.Pipeline"}, &1))
    refute Enum.any?(attributes, &match?({%Span{}, "producer", _}, &1))
  end

  test "sets no producer attribute on a message's span without producer metadata, as before Broadway 1.3" do
    metadata = metadata() |> Map.delete(:producer) |> Map.put(:message, %{data: "data"})
    Appsignal.Broadway.broadway_processor_message_start([], %{}, metadata, :ok)

    {:ok, attributes} = Test.Span.get(:set_attribute)
    assert Enum.any?(attributes, &match?({%Span{}, "topology_name", "MyApp.Pipeline"}, &1))
    refute Enum.any?(attributes, &match?({%Span{}, "producer", _}, &1))
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
