defmodule Appsignal.ObanTest do
  use ExUnit.Case
  alias Appsignal.{FakeAppsignal, Span, Test}

  test "attaches to Oban events automatically" do
    assert attached?([:oban, :job, :start])
    assert attached?([:oban, :job, :stop])
    assert attached?([:oban, :job, :exception])
    assert attached?([:oban, :engine, :insert_job, :start])
    assert attached?([:oban, :engine, :insert_job, :stop])
    assert attached?([:oban, :engine, :insert_job, :exception])
  end

  describe "oban_job_start/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

      execute_job_start()
    end

    @tag :skip
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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
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

  describe "oban_job_stop/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start()

      execute_job_stop()

      [fake_appsignal: fake_appsignal]
    end

    test "closes a span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
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

  describe "oban_job_stop/4, with a :result metadata key (v2.5.0)" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

      execute_job_start()

      execute_job_stop(%{
        result: {:ok, 42}
      })
    end

    test "sets the result attribute" do
      assert attribute?("result", "{:ok, 42}")
    end
  end

  describe "oban_job_exception/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start()

      execute_job_exception()

      [fake_appsignal: fake_appsignal]
    end

    @tag :skip
    test "closes a span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      fake_appsignal = start_supervised!(FakeAppsignal)

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

  describe "oban_insert_job_start/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      execute_insert_job(:start)
    end

    test "creates a child span" do
      assert {:ok, [{"oban", nil}]} = Test.Tracer.get(:create_span)
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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

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
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

      execute_insert_job(:start)

      execute_insert_job(:stop)

      execute_insert_job(:start)

      execute_insert_job(:exception)
    end

    @tag :skip
    test "closes a span" do
      assert {:ok, [{%Span{}}, {%Span{}}]} = Test.Tracer.get(:close_span)
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

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key
    end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Oban, event}
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
end
