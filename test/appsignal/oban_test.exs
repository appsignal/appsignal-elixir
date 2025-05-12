defmodule Appsignal.ObanTest do
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

  test "attaches to Oban events automatically" do
    assert attached?([:oban, :job, :start])
    assert attached?([:oban, :job, :stop])
    assert attached?([:oban, :job, :exception])
    assert attached?([:oban, :engine, :insert_job, :start])
    assert attached?([:oban, :engine, :insert_job, :stop])
    assert attached?([:oban, :engine, :insert_job, :exception])
  end

  describe "when :instrument_oban is set to false" do
    setup do
      :telemetry.detach({Appsignal.Oban, [:oban, :job, :start]})
      :telemetry.detach({Appsignal.Oban, [:oban, :job, :stop]})
      :telemetry.detach({Appsignal.Oban, [:oban, :job, :exception]})
      :telemetry.detach({Appsignal.Oban, [:oban, :engine, :insert_job, :start]})
      :telemetry.detach({Appsignal.Oban, [:oban, :engine, :insert_job, :stop]})
      :telemetry.detach({Appsignal.Oban, [:oban, :engine, :insert_job, :exception]})

      with_config(%{instrument_oban: false}, fn -> Appsignal.start([], []) end)

      on_exit(fn ->
        [:ok, :ok, :ok, :ok, :ok, :ok] = Appsignal.Oban.attach()
      end)
    end

    test "does not attach to Oban events" do
      assert !attached?([:oban, :job, :start])
      assert !attached?([:oban, :job, :stop])
      assert !attached?([:oban, :job, :exception])
      assert !attached?([:oban, :engine, :insert_job, :start])
      assert !attached?([:oban, :engine, :insert_job, :stop])
      assert !attached?([:oban, :engine, :insert_job, :exception])
    end
  end

  describe "oban_job_start/4" do
    setup do
      execute_job_start()
    end

    test "creates a span" do
      assert {:ok, [{"oban"}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Test.Worker#perform"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "job.oban")
    end

    test "sets job arguments as span params" do
      assert {:ok, [{%Span{}, "params", %{foo: "bar"}}]} = Test.Span.get(:set_sample_data)
    end

    test "sets job attributes as span tags" do
      assert attribute?("id", 123)
      assert attribute?("worker", "Test.Worker")
      assert attribute?("queue", "default")
      assert attribute?("attempt", 1)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :job, :start])
    end
  end

  describe "oban_job_start/4, with a :tags metadata key (v2.1.0)" do
    setup do
      execute_job_start(%{
        tags: ["foo", "bar"]
      })
    end

    test "sets job tags as span tags" do
      assert attribute?("job_tag_foo", true)
      assert attribute?("job_tag_bar", true)
    end
  end

  describe "oban_job_start/4, with a :job metadata key (v2.3.1)" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start(%{
        job: sample_job()
      })

      [fake_appsignal: fake_appsignal]
    end

    test "sets job priority as a span tag" do
      assert attribute?("priority", 0)
    end

    test "sets job meta as span tags" do
      assert attribute?("job_meta_number", 123)
      assert attribute?("job_meta_string", "foo")
      assert attribute?("job_meta_atom", ":bar")
      assert attribute?("job_meta_boolean", true)
      assert !has_attribute?("job_meta_other")
    end

    test "adds job queue time distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 3000, tags: %{queue: "default"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_queue_time")
    end
  end

  describe "oban_job_start/4, with a :conf metadata key (v2.4.0)" do
    test "sets the prefix as a span tag if present" do
      execute_job_start(%{
        conf: sample_conf(prefix: "foo")
      })

      assert attribute?("prefix", "foo")
    end

    test "does not set the prefix as a span tag if not present" do
      execute_job_start(%{
        conf: sample_conf()
      })

      assert !has_attribute?("prefix")
    end
  end

  describe "oban_job_stop/4" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start()
      span = Tracer.current_span()
      execute_job_stop()

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "sets the state attribute to success" do
      assert attribute?("state", "success")
    end

    test "increments job stop counter", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 1, tags: %{state: "success"}},
               %{key: _, value: 1, tags: %{state: "success", queue: "default"}},
               %{key: _, value: 1, tags: %{state: "success", worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 1,
                 tags: %{state: "success", worker: "Test.Worker", queue: "default"}
               }
             ] = FakeAppsignal.get_counters(fake_appsignal, "oban_job_count")
    end

    test "adds job duration distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 123, tags: %{worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 123,
                 tags: %{hostname: "Bobs-MBP.example.com", worker: "Test.Worker"}
               },
               %{key: _, value: 123, tags: %{state: "success", worker: "Test.Worker"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_duration")
    end

    test "does not detach the handler" do
      assert attached?([:oban, :job, :stop])
    end
  end

  describe "oban_job_stop/4, with a :state metadata key (v2.4.0)" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start()

      execute_job_stop(%{
        state: "snoozed"
      })

      [fake_appsignal: fake_appsignal]
    end

    test "sets the state attribute" do
      assert attribute?("state", "snoozed")
    end

    test "increments job stop counter", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 1, tags: %{state: "snoozed"}},
               %{key: _, value: 1, tags: %{state: "snoozed", queue: "default"}},
               %{key: _, value: 1, tags: %{state: "snoozed", worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 1,
                 tags: %{state: "snoozed", worker: "Test.Worker", queue: "default"}
               }
             ] = FakeAppsignal.get_counters(fake_appsignal, "oban_job_count")
    end

    test "adds job duration distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 123, tags: %{worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 123,
                 tags: %{hostname: "Bobs-MBP.example.com", worker: "Test.Worker"}
               },
               %{key: _, value: 123, tags: %{state: "snoozed", worker: "Test.Worker"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_duration")
    end
  end

  describe "oban_job_stop/4, with a :result metadata value (v2.5.0)" do
    test "sets the result attribute" do
      [
        {:ok, "ok", nil},
        {:discard, "discard", nil},
        {{:cancel, "cancel reason"}, "cancel", "cancel reason"},
        {{:discard, "discard reason"}, "discard", "discard reason"},
        {{:ok, "something"}, "ok", nil},
        {{:error, "error reason"}, "error", "error reason"},
        {{:snooze, 1_001}, "snooze", "1001"},

        # Testing some non-string values and their conversions into strings
        {{:cancel, :my_reason}, "cancel", "my_reason"},
        {{:cancel, true}, "cancel", "true"},
        {{:cancel, false}, "cancel", "false"},
        {{:cancel, -12.35}, "cancel", "-12.35"},
        {{:cancel, [abc: :def]}, "cancel", "[abc: :def]"},
        {{:cancel, 0..255}, "cancel", "0..255"},
        {"other value", "ok", nil}
      ]
      |> Enum.each(fn {return_value, expected_value, expected_reason} ->
        execute_job_start()

        execute_job_stop(%{result: return_value})

        assert attribute?("result", expected_value)

        if expected_reason do
          assert attribute?("result_reason", expected_reason)
        end
      end)
    end
  end

  describe "oban_job_exception/4" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      with_config(%{}, &Appsignal.Oban.attach/0)

      execute_job_start()
      span = Tracer.current_span()
      execute_job_exception()

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "sets the state attribute to failure" do
      assert attribute?("state", "failure")
    end

    test "adds the error to the span" do
      assert {:ok,
              [
                {
                  %Span{},
                  :error,
                  %RuntimeError{message: "Exception!"},
                  [{Appsignal.ObanTest, :execute_job_exception, _, _} | _]
                }
              ]} = Test.Span.get(:add_error)
    end

    test "increments job stop counter", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 1, tags: %{state: "failure"}},
               %{key: _, value: 1, tags: %{state: "failure", queue: "default"}},
               %{key: _, value: 1, tags: %{state: "failure", worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 1,
                 tags: %{state: "failure", worker: "Test.Worker", queue: "default"}
               }
             ] = FakeAppsignal.get_counters(fake_appsignal, "oban_job_count")
    end

    test "adds job duration distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 123, tags: %{worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 123,
                 tags: %{hostname: "Bobs-MBP.example.com", worker: "Test.Worker"}
               },
               %{key: _, value: 123, tags: %{state: "failure", worker: "Test.Worker"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_duration")
    end

    test "does not detach the handler" do
      assert attached?([:oban, :job, :exception])
    end
  end

  describe "oban_job_exception/4, with a :state metadata key (v2.4.0)" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      with_config(%{}, &Appsignal.Oban.attach/0)

      execute_job_start()

      execute_job_exception(%{
        state: "discard"
      })

      [fake_appsignal: fake_appsignal]
    end

    test "sets the state attribute to the job's state" do
      assert attribute?("state", "discard")
    end

    test "increments job stop counter", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 1, tags: %{state: "discard"}},
               %{key: _, value: 1, tags: %{state: "discard", queue: "default"}},
               %{key: _, value: 1, tags: %{state: "discard", worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 1,
                 tags: %{state: "discard", worker: "Test.Worker", queue: "default"}
               }
             ] = FakeAppsignal.get_counters(fake_appsignal, "oban_job_count")
    end

    test "adds job duration distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 123, tags: %{worker: "Test.Worker"}},
               %{
                 key: _,
                 value: 123,
                 tags: %{hostname: "Bobs-MBP.example.com", worker: "Test.Worker"}
               },
               %{key: _, value: 123, tags: %{state: "discard", worker: "Test.Worker"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_duration")
    end
  end

  describe "oban_job_discard/4, with no :state metadata key" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      with_config(
        %{report_oban_errors: "discard"},
        &Appsignal.Oban.attach/0
      )

      execute_job_start()
      span = Tracer.current_span()
      execute_job_exception()

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "adds the error to the span" do
      assert {:ok,
              [
                {
                  %Span{},
                  :error,
                  %RuntimeError{message: "Exception!"},
                  [{Appsignal.ObanTest, :execute_job_exception, _, _} | _]
                }
              ]} = Test.Span.get(:add_error)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :job, :exception])
    end
  end

  describe "oban_job_discard/4, with a :state metadata key set to discard" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      with_config(
        %{report_oban_errors: "discard"},
        &Appsignal.Oban.attach/0
      )

      execute_job_start()
      span = Tracer.current_span()

      execute_job_exception(%{
        state: "discard"
      })

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "sets the state attribute to failure" do
      assert attribute?("state", "discard")
    end

    test "adds the error to the span" do
      assert {:ok,
              [
                {
                  %Span{},
                  :error,
                  %RuntimeError{message: "Exception!"},
                  [{Appsignal.ObanTest, :execute_job_exception, _, _} | _]
                }
              ]} = Test.Span.get(:add_error)
    end
  end

  describe "oban_job_discard/4, with a :state metadata key set to failure" do
    setup do
      fake_appsignal = start_supervised!(FakeAppsignal)

      with_config(
        %{report_oban_errors: "discard"},
        &Appsignal.Oban.attach/0
      )

      execute_job_start()
      span = Tracer.current_span()

      execute_job_exception(%{
        state: "failure"
      })

      [span: span, fake_appsignal: fake_appsignal]
    end

    test "closes the span", %{span: span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {span})
    end

    test "sets the state attribute to failure" do
      assert attribute?("state", "failure")
    end

    test "does not add the error to the span" do
      assert :error = Test.Span.get(:add_error)
    end
  end

  describe ":report_oban_errors config option" do
    test "attaches oban_job_exception/4 to [:oban, :job, :exception] when unset" do
      with_config(%{}, &Appsignal.Oban.attach/0)

      assert attached?(
               [:oban, :job, :exception],
               &Appsignal.Oban.oban_job_exception/4
             )
    end

    test "attaches oban_job_exception/4 to [:oban, :job, :exception] when set to all" do
      with_config(
        %{report_oban_errors: "all"},
        &Appsignal.Oban.attach/0
      )

      assert attached?(
               [:oban, :job, :exception],
               &Appsignal.Oban.oban_job_exception/4
             )
    end

    test "attaches oban_job_discard/4 to [:oban, :job, :exception] when set to discard" do
      with_config(
        %{report_oban_errors: "discard"},
        &Appsignal.Oban.attach/0
      )

      assert attached?(
               [:oban, :job, :exception],
               &Appsignal.Oban.oban_job_discard/4
             )
    end

    test "attaches oban_job_stop/4 to [:oban, :job, :exception] when set to none" do
      with_config(
        %{report_oban_errors: "none"},
        &Appsignal.Oban.attach/0
      )

      assert attached?(
               [:oban, :job, :exception],
               &Appsignal.Oban.oban_job_stop/4
             )
    end
  end

  describe "oban_insert_job_start/4, without a root span" do
    setup do
      execute_insert_job(:start)
    end

    test "does not create a child span" do
      assert :error = Test.Tracer.get(:create_span)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :start])
    end
  end

  describe "oban_insert_job_start/4" do
    setup do
      Appsignal.Tracer.create_span("http_request")

      execute_insert_job(:start)
    end

    test "creates a child span" do
      assert {:ok, [{"oban", %Span{}}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Insert job (Test.Worker)"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "insert_job.oban")
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :start])
    end
  end

  describe "oban_insert_job_start/4, without a changeset" do
    setup do
      Appsignal.Tracer.create_span("http_request")

      execute_insert_job(:start, %{})
    end

    test "sets the span's name without the worker" do
      assert {:ok, [{%Span{}, "Insert job"}]} = Test.Span.get(:set_name)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :start])
    end
  end

  describe "oban_insert_job_stop/4 and oban_insert_job_exception/4" do
    setup do
      execute_insert_job(:start)
      first_span = Tracer.current_span()
      execute_insert_job(:stop)

      execute_insert_job(:start)
      second_span = Tracer.current_span()
      execute_insert_job(:exception)

      [first_span: first_span, second_span: second_span]
    end

    test "closes both spans", %{first_span: first_span, second_span: second_span} do
      {:ok, closed_spans} = Test.Tracer.get(:close_span)
      assert Enum.member?(closed_spans, {first_span})
      assert Enum.member?(closed_spans, {second_span})
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :stop])
      assert attached?([:oban, :engine, :insert_job, :exception])
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
      end && id == {Appsignal.Oban, event}
    end)
  end

  defp execute_job_start(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:oban, :job, :start],
      %{},
      Map.merge(sample_metadata(), additional_metadata)
    )
  end

  defp execute_job_stop(additional_metadata \\ %{}) do
    :telemetry.execute(
      [:oban, :job, :stop],
      %{duration: 123 * 1_000_000},
      Map.merge(sample_metadata(), additional_metadata)
    )
  end

  defp execute_job_exception(additional_metadata \\ %{}) do
    try do
      raise "Exception!"
    catch
      kind, reason ->
        metadata =
          Map.merge(sample_metadata(), %{
            kind: kind,
            error: reason,
            stacktrace: __STACKTRACE__
          })

        :telemetry.execute(
          [:oban, :job, :exception],
          %{duration: 123 * 1_000_000},
          Map.merge(metadata, additional_metadata)
        )
    end
  end

  defp execute_insert_job(phase, changeset \\ sample_changeset()) do
    :telemetry.execute(
      [:oban, :engine, :insert_job, phase],
      %{},
      %{
        changeset: changeset
      }
    )
  end

  defp sample_metadata do
    %{
      worker: :"Test.Worker",
      args: %{foo: "bar"},
      id: 123,
      queue: :default,
      attempt: 1
    }
  end

  defp sample_job do
    %{
      priority: 0,
      scheduled_at: DateTime.from_unix!(1_234_000_000),
      attempted_at: DateTime.from_unix!(1_234_000_003),
      meta: %{
        number: 123,
        string: "foo",
        atom: :bar,
        boolean: true,
        other: [:ignore, :me]
      }
    }
  end

  defp sample_changeset do
    %{
      changes: %{
        worker: :"Test.Worker"
      }
    }
  end

  defp sample_conf(opts \\ []) do
    Appsignal.ObanTest.ObanConfig.new(opts)
  end
end

# A struct that emulates the `Oban.Config` struct:
# https://github.com/oban-bg/oban/blob/8b0aada8b2bdbe7a338c34c87a5f3c079e9800ad/lib/oban/config.ex#L32-L47
defmodule Appsignal.ObanTest.ObanConfig do
  @moduledoc false

  defstruct prefix: false

  # A subset of `Oban.Config`'s typing:
  # https://hexdocs.pm/oban/Oban.Config.html#t:t/0
  @type t :: %__MODULE__{
          prefix: false | String.t()
        }

  @doc false
  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
