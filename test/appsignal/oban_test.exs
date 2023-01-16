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
      fake_appsignal = start_supervised!(FakeAppsignal)

      execute_job_start()

      [fake_appsignal: fake_appsignal]
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
      assert attribute?("queue", "default")
      assert attribute?("attempt", 1)
      assert attribute?("priority", 0)
    end

    test "sets job tags as span tags" do
      assert attribute?("job_tag_foo", "bar")
      assert attribute?("job_tag_baz", 123)
    end

    test "adds job queue time distribution value", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: _, value: 3000, tags: %{queue: "default"}}
             ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_queue_time")
    end

    test "does not detach the handler" do
      assert attached?([:oban, :job, :start])
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

    test "sets the job state and result as span tags" do
      assert attribute?("state", "success")
      assert attribute?("result", ":ok")
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

    test "closes a span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "sets the job state and worker as span tags" do
      assert attribute?("state", "success")
      assert attribute?("worker", "Test.Worker")
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
      assert attached?([:oban, :job, :exception])
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

    test "creates a child span" do
      assert {:ok, [{"oban", nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Insert job"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "insert_job.oban")
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :start])
    end
  end

  describe "oban_insert_job_stop/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

      execute_insert_job(:start)

      execute_insert_job(:stop)
    end

    test "closes a span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :stop])
    end
  end

  describe "oban_insert_job_exception/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeAppsignal)

      execute_insert_job(:start)

      execute_insert_job(:exception)
    end

    test "closes a span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "does not detach the handler" do
      assert attached?([:oban, :engine, :insert_job, :exception])
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
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Oban, event}
    end)
  end

  defp execute_job_start do
    :telemetry.execute(
      [:oban, :job, :start],
      %{},
      %{
        job: sample_job()
      }
    )
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

  defp execute_job_stop do
    :telemetry.execute(
      [:oban, :job, :stop],
      %{duration: 123 * 1_000_000},
      %{
        job: sample_job(),
        state: :success,
        result: :ok
      }
    )
  end

  defp execute_job_exception do
    try do
      raise "Exception!"
    catch
      kind, reason ->
        :telemetry.execute(
          [:oban, :job, :exception],
          %{duration: 123 * 1_000_000},
          %{
            job: sample_job(),
            state: :success,
            kind: kind,
            reason: reason,
            stacktrace: __STACKTRACE__
          }
        )
    end
  end

  defp sample_job do
    %{
      worker: :"Test.Worker",
      args: %{foo: "bar"},
      id: 123,
      queue: :default,
      attempt: 1,
      priority: 0,
      tags: [foo: "bar", baz: 123],
      scheduled_at: DateTime.from_unix!(1_234_000_000),
      attempted_at: DateTime.from_unix!(1_234_000_003)
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
