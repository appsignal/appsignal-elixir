if Appsignal.Dependencies.present?(:oban) do
  defmodule AppsignalTest.Oban.Migration do
    use Ecto.Migration

    def up, do: Oban.Migration.up()
    def down, do: Oban.Migration.down()
  end

  defmodule AppsignalTest.Oban.Worker do
    use Oban.Worker, queue: :default

    @impl Oban.Worker
    def perform(%Oban.Job{args: %{"result" => result}}), do: result(result)

    defp result("ok"), do: :ok
    defp result("ok_value"), do: {:ok, "value"}
    defp result("raise"), do: raise("Job failed!")
    defp result("throw"), do: throw(:thrown)
    defp result("error"), do: {:error, "Job errored!"}
    defp result("cancel"), do: {:cancel, "Job cancelled!"}
    defp result("cancel_atom"), do: {:cancel, :no_longer_needed}
    defp result("cancel_term"), do: {:cancel, abc: :def}
    defp result("discard"), do: {:discard, "Job discarded!"}
    defp result("snooze"), do: {:snooze, 60}
    defp result("other"), do: "something else"

    defp result("query") do
      Appsignal.Test.Repo.all(AppsignalTest.Ecto.Movie)
      :ok
    end

    defp result("enqueue") do
      {:ok, _job} = Oban.insert(new(%{result: "ok"}))
      :ok
    end
  end

  defmodule Appsignal.ObanTest do
    use AppsignalTest.IntegrationCase
    import AppsignalTest.Utils, only: [with_config: 2]
    alias Appsignal.FakeAppsignal
    alias Appsignal.Test.Repo
    alias AppsignalTest.Ecto.{Database, Migration}
    alias AppsignalTest.Oban.Worker

    @worker "AppsignalTest.Oban.Worker"
    @perform "AppsignalTest.Oban.Worker#perform"

    setup do
      Database.start(Repo, [Migration, AppsignalTest.Oban.Migration])
      :ok
    end

    describe "running jobs through Oban" do
      setup :start_oban

      test "runs a job" do
        insert!(%{result: "ok"})
        assert %{success: 1} = Oban.drain_queue(queue: :default)
      end

      test "runs a job inserted by another job" do
        insert!(%{result: "enqueue"})
        assert %{success: 2} = Oban.drain_queue(queue: :default, with_recursion: true)
      end

      test "inserts a job" do
        assert %Oban.Job{state: "available"} = instrumented(fn -> insert!(%{result: "ok"}) end)
      end

      test "raises the error when inserting a job fails" do
        Ecto.Adapters.SQL.query!(Repo, "DROP TABLE oban_jobs")

        assert_raise Exqlite.Error, fn ->
          instrumented(fn -> insert!(%{result: "ok"}) end)
        end
      end
    end

    describe "the span recorded for a job" do
      setup :start_oban

      test "is a root span in the oban namespace, with the job's attributes" do
        job =
          insert!(%{result: "ok"},
            tags: ["important", "billing"],
            meta: %{"number" => 123, "string" => "foo", "list" => [1, 2]},
            priority: 2,
            queue: :mailers
          )

        Oban.drain_queue(queue: :mailers)

        assert [span, _ack] = spans()
        assert span["name"] == @perform
        assert span["namespace"] == "oban"
        assert span["parent_span_id"] == ""
        assert span["error"] == nil
        assert category(span) == "job.oban"
        assert span["sample_data"]["params"] == %{"result" => "ok"}

        assert Map.delete(span["attributes"], "appsignal:category") == %{
                 "id" => job.id,
                 "worker" => @worker,
                 "queue" => "mailers",
                 "attempt" => 1,
                 "priority" => 2,
                 "state" => "success",
                 "result" => "ok",
                 "job_tag_important" => true,
                 "job_tag_billing" => true,
                 "job_meta_number" => 123,
                 "job_meta_string" => "foo"
               }
      end

      test "has an ok result for a job that returns a value" do
        assert [%{"attributes" => %{"state" => "success", "result" => "ok"}}] =
                 run(%{result: "ok_value"})
      end

      test "has an ok result for a job that returns something else" do
        assert [%{"attributes" => %{"state" => "success", "result" => "ok"}}] =
                 run(%{result: "other"})
      end

      test "has the error for a job that raises" do
        assert [span] = run(%{result: "raise"})
        assert span["attributes"]["state"] == "failure"
        refute Map.has_key?(span["attributes"], "result")

        assert %{"name" => "RuntimeError", "message" => "** (RuntimeError) Job failed!"} =
                 span["error"]

        assert span["error"]["backtrace_json"] =~ "AppsignalTest.Oban.Worker.result/1"
      end

      test "has Oban's crash error for a job that throws" do
        assert [%{"error" => %{"name" => "Oban.CrashError"}}] = run(%{result: "throw"})
      end

      test "has the error and the discard state for a job that raises on its last attempt" do
        assert [span] = run(%{result: "raise"}, max_attempts: 1)
        assert span["attributes"]["state"] == "discard"
        assert span["error"]["name"] == "RuntimeError"
      end

      test "has Oban's error for a job that returns an error" do
        assert [span] = run(%{result: "error"})
        assert span["attributes"]["state"] == "failure"

        assert span["error"] == %{
                 "name" => "Oban.PerformError",
                 "message" =>
                   ~s|** (Oban.PerformError) AppsignalTest.Oban.Worker failed with {:error, "Job errored!"}|,
                 "backtrace" => [],
                 "backtrace_json" => "[]"
               }
      end

      test "has the reason, and no error, for a job that cancels" do
        assert [span] = run(%{result: "cancel"})
        assert span["error"] == nil

        assert %{
                 "state" => "cancelled",
                 "result" => "cancel",
                 "result_reason" => "Job cancelled!"
               } = span["attributes"]
      end

      test "has a cancel reason that is not a string as a string" do
        assert [%{"attributes" => %{"result_reason" => "no_longer_needed"}}] =
                 run(%{result: "cancel_atom"})

        assert [_, %{"attributes" => %{"result_reason" => "[abc: :def]"}}] =
                 run(%{result: "cancel_term"})
      end

      test "has the reason, and no error, for a job that discards" do
        assert [span] = run(%{result: "discard"})
        assert span["error"] == nil

        assert %{"state" => "discard", "result" => "discard", "result_reason" => "Job discarded!"} =
                 span["attributes"]
      end

      test "has the period as the reason, and no error, for a job that snoozes" do
        assert [span] = run(%{result: "snooze"})
        assert span["error"] == nil

        assert %{"state" => "snoozed", "result" => "snooze", "result_reason" => "60"} =
                 span["attributes"]
      end
    end

    describe "the span recorded for a job, with report_oban_errors set to discard" do
      setup [:start_oban, :report_oban_errors_discard]

      test "has the error of a job on its last attempt" do
        assert [span] = run(%{result: "raise"}, max_attempts: 1)
        assert span["attributes"]["state"] == "discard"
        assert span["error"]["name"] == "RuntimeError"
      end

      test "has no error, and an ok result, for a job that will be retried" do
        assert [span] = run(%{result: "raise"})
        assert span["error"] == nil
        assert %{"state" => "failure", "result" => "ok"} = span["attributes"]
      end
    end

    describe "the span recorded for a job, with report_oban_errors set to none" do
      setup [:start_oban, :report_oban_errors_none]

      test "has no error, and an ok result, for a job on its last attempt" do
        assert [span] = run(%{result: "raise"}, max_attempts: 1)
        assert span["error"] == nil
        assert %{"state" => "discard", "result" => "ok"} = span["attributes"]
      end

      test "has an error result without the error" do
        assert [span] = run(%{result: "error"})
        assert span["error"] == nil
        assert %{"result" => "error", "result_reason" => "Job errored!"} = span["attributes"]
      end
    end

    describe "the child spans recorded for a job" do
      setup :start_oban

      test "include the queries it runs and Oban's own" do
        insert!(%{result: "query"})
        Oban.drain_queue(queue: :default)

        assert [job, query, ack] = spans()
        assert job["name"] == @perform
        assert query["parent_span_id"] == job["span_id"]
        assert query["attributes"]["appsignal:body"] =~ ~s|FROM "movies"|
        assert ack["parent_span_id"] == job["span_id"]
        assert ack["attributes"]["appsignal:body"] =~ ~s|UPDATE "oban_jobs"|
      end

      test "include the insert of a job it inserts, which is recorded as a root span" do
        insert!(%{result: "enqueue"})
        Oban.drain_queue(queue: :default, with_recursion: true)

        assert [parent, insert, _insert_query, _ack, child, _child_ack] = spans()
        assert parent["name"] == @perform
        assert insert["name"] == "Insert job (#{@worker})"
        assert insert["parent_span_id"] == parent["span_id"]
        assert child["name"] == @perform
        assert child["parent_span_id"] == ""
      end
    end

    describe "the spans recorded for inserting a job" do
      setup :start_oban

      test "include an insert span with the insert query inside it" do
        instrumented(fn -> insert!(%{result: "ok"}) end)

        assert [root, insert, query] = spans()
        assert insert["name"] == "Insert job (#{@worker})"
        assert category(insert) == "insert_job.oban"
        assert insert["parent_span_id"] == root["span_id"]
        assert query["parent_span_id"] == insert["span_id"]
        assert query["attributes"]["appsignal:body"] =~ ~s|INSERT INTO "oban_jobs"|
      end

      test "include an insert span without an error when the insert fails" do
        Ecto.Adapters.SQL.query!(Repo, "DROP TABLE oban_jobs")

        assert_raise Exqlite.Error, fn ->
          instrumented(fn -> insert!(%{result: "ok"}) end)
        end

        assert [_root, insert, _query] = spans()
        assert insert["name"] == "Insert job (#{@worker})"
        assert insert["error"] == nil
      end

      test "include the queries, but no insert span, for insert_all" do
        instrumented(fn ->
          Oban.insert_all([Worker.new(%{result: "ok"}), Worker.new(%{result: "ok"})])
        end)

        assert [root | queries] = spans()
        assert queries != []
        assert Enum.all?(queries, &(category(&1) == "query.ecto"))
        assert Enum.all?(queries, &(&1["parent_span_id"] == root["span_id"]))
      end
    end

    describe "inserts that record no span" do
      setup :start_oban

      test "outside an instrumented function" do
        insert!(%{result: "ok"})
        assert spans() == []
      end
    end

    describe "the metrics recorded for a job" do
      setup :start_oban

      setup do
        [fake_appsignal: start_supervised!(FakeAppsignal)]
      end

      test "count jobs by worker, queue and state", %{fake_appsignal: fake_appsignal} do
        run(%{result: "ok"})
        run(%{result: "raise"})

        counters = FakeAppsignal.get_counters(fake_appsignal, "oban_job_count")

        for state <- ["success", "failure"] do
          for tags <- [
                %{worker: @worker, queue: "default", state: state},
                %{worker: @worker, state: state},
                %{queue: "default", state: state},
                %{state: state}
              ] do
            assert %{value: 1} = Enum.find(counters, &(&1.tags == tags))
          end
        end

        assert length(counters) == 8
      end

      test "record job durations by worker, state and hostname", %{
        fake_appsignal: fake_appsignal
      } do
        run(%{result: "ok"})

        assert [
                 %{tags: %{worker: @worker}, value: duration},
                 %{tags: %{worker: @worker, hostname: "Bobs-MBP.example.com"}, value: duration},
                 %{tags: %{worker: @worker, state: "success"}, value: duration}
               ] = FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_duration")

        assert is_float(duration) and duration >= 0
      end

      test "record the time a job waited in its queue", %{fake_appsignal: fake_appsignal} do
        run(%{result: "ok"})

        assert [%{tags: %{queue: "default"}, value: queue_time}] =
                 FakeAppsignal.get_distribution_values(fake_appsignal, "oban_job_queue_time")

        assert is_float(queue_time) and queue_time >= 0
      end
    end

    describe "jobs run by a running queue" do
      setup do
        start_supervised!(
          {Oban, repo: Repo, engine: Oban.Engines.Lite, queues: [default: 2], plugins: false}
        )

        :ok
      end

      test "are each recorded in the process that runs them" do
        %{id: ok_id} = insert!(%{result: "ok"})
        %{id: raise_id} = insert!(%{result: "raise"})

        jobs =
          fn spans -> all_closed?(spans) and length(named(spans, @perform)) == 2 end
          |> await_spans()
          |> named(@perform)
          |> Map.new(&{&1["attributes"]["id"], &1})

        assert %{"error" => nil} = jobs[ok_id]
        assert %{"error" => %{"name" => "RuntimeError"}} = jobs[raise_id]
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to Oban's job and insert events" do
        for event <- events() do
          assert attached?(Appsignal.Oban, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_oban set to false" do
      @describetag :detaches_handlers

      setup do
        for event <- events(), do: :telemetry.detach({Appsignal.Oban, event})

        ExUnit.CaptureLog.capture_log(fn ->
          with_config(%{instrument_oban: false}, fn -> Appsignal.start([], []) end)
        end)

        :ok
      end

      test "does not attach to Oban's job and insert events" do
        for event <- events() do
          refute attached?(Appsignal.Oban, event)
        end
      end

      test "records no span for a job" do
        start_oban(%{})
        run(%{result: "ok"})
        assert spans() == []
      end
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp start_oban(_context) do
      start_supervised!({Oban, repo: Repo, engine: Oban.Engines.Lite, testing: :manual})
      :ok
    end

    defp report_oban_errors_discard(_context), do: report_oban_errors("discard")
    defp report_oban_errors_none(_context), do: report_oban_errors("none")

    defp report_oban_errors(value) do
      with_config(%{report_oban_errors: value}, &Appsignal.Oban.attach/0)
      on_exit(&Appsignal.Oban.attach/0)
      :ok
    end

    defp insert!(args, opts \\ []) do
      {:ok, job} = args |> Worker.new(opts) |> Oban.insert()
      job
    end

    defp run(args, opts \\ []) do
      insert!(args, opts)
      Oban.drain_queue(queue: Keyword.get(opts, :queue, :default))
      spans() |> named(@perform)
    end

    defp events do
      [
        [:oban, :job, :start],
        [:oban, :job, :stop],
        [:oban, :job, :exception],
        [:oban, :engine, :insert_job, :start],
        [:oban, :engine, :insert_job, :stop],
        [:oban, :engine, :insert_job, :exception]
      ]
    end
  end
end

defmodule Appsignal.Oban.EventTest do
  use ExUnit.Case
  import AppsignalTest.Spans, only: [spans: 0]
  alias Appsignal.{FakeAppsignal, Span, Test}

  @moduletag :skip_env_test_no_nif

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)
    start_supervised!(FakeAppsignal)
    :ok
  end

  test "sets the prefix from the :conf metadata as an attribute" do
    span = job_start(%{conf: %{prefix: "private"}})
    assert %{"attributes" => %{"prefix" => "private"}} = Span.to_map(span)
  end

  test "sets job meta values that are atoms as inspected strings, and skips other terms" do
    span =
      job_start(%{
        job: %{
          priority: 0,
          scheduled_at: ~U[2026-01-01 00:00:00.000000Z],
          attempted_at: ~U[2026-01-01 00:00:01.000000Z],
          meta: %{atom: :bar, boolean: true, other: [:ignore, :me]}
        }
      })

    assert %{"attributes" => attributes} = Span.to_map(span)
    assert attributes["job_meta_atom"] == ":bar"
    assert attributes["job_meta_boolean"] == true
    refute Map.has_key?(attributes, "job_meta_other")
  end

  describe "for Oban versions without the :state metadata key" do
    test "a stop event records the success state" do
      job_start()
      Appsignal.Oban.oban_job_stop([:oban, :job, :stop], %{duration: 1_000}, metadata(), :ok)
      assert [%{"attributes" => %{"state" => "success"}}] = spans()
    end

    test "an exception event records the failure state and the error" do
      job_start()
      job_exception(&Appsignal.Oban.oban_job_exception/4)

      assert [%{"attributes" => %{"state" => "failure"}, "error" => %{"name" => "RuntimeError"}}] =
               spans()
    end

    test "an exception event reported on discard records the error" do
      job_start()
      job_exception(&Appsignal.Oban.oban_job_discard/4)
      assert [%{"error" => %{"name" => "RuntimeError"}}] = spans()
    end
  end

  test "an exception event without a started span records a span of its own" do
    job_exception(&Appsignal.Oban.oban_job_exception/4)

    assert [span] = spans()
    assert span["name"] == "Test.Worker#perform"
    assert span["error"]["name"] == "RuntimeError"
  end

  test "an insert event without a changeset names the span without the worker" do
    parent = Appsignal.Tracer.create_span("http_request")

    span =
      Appsignal.Oban.oban_insert_job_start([:oban, :engine, :insert_job, :start], %{}, %{}, :ok)

    assert %{"name" => "Insert job"} = Span.to_map(span)
    Appsignal.Tracer.close_span(span)
    Appsignal.Tracer.close_span(parent)
  end

  defp job_start(metadata \\ %{}) do
    Appsignal.Oban.oban_job_start(
      [:oban, :job, :start],
      %{},
      Map.merge(metadata(), metadata),
      :ok
    )
  end

  defp job_exception(handler) do
    raise "Exception!"
  catch
    kind, reason ->
      metadata = Map.merge(metadata(), %{kind: kind, error: reason, stacktrace: __STACKTRACE__})
      handler.([:oban, :job, :exception], %{duration: 1_000}, metadata, :ok)
  end

  defp metadata do
    %{worker: :"Test.Worker", args: %{foo: "bar"}, id: 123, queue: :default, attempt: 1}
  end
end
