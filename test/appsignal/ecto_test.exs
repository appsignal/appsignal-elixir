if Appsignal.Dependencies.present?(:ecto_sql) do
  defmodule AppsignalTest.Ecto.OtherRepo do
    use Ecto.Repo, otp_app: :appsignal, adapter: Ecto.Adapters.SQLite3
  end

  defmodule Appsignal.EctoTest do
    use AppsignalTest.IntegrationCase
    import AppsignalTest.Utils, only: [with_config: 2]
    import Ecto.Query
    alias Appsignal.FakeAppsignal
    alias Appsignal.Test.Repo
    alias AppsignalTest.Ecto.{Actor, Character, Database, Movie, OtherRepo}

    setup do
      Database.start(Repo)
      :ok
    end

    describe "running queries through Ecto" do
      test "returns what the repo returns" do
        movie = instrumented(fn -> Repo.insert!(%Movie{title: "The Room"}) end)

        assert %Movie{id: id, title: "The Room"} = movie
        assert Repo.get!(Movie, id) == movie
      end

      test "preloads associations from parallel tasks" do
        insert_movie()

        [movie] =
          instrumented(fn -> Repo.all(from(m in Movie, preload: [:characters, :actors])) end)

        assert [%Character{name: "Tommy"}] = movie.characters
        assert [%Actor{name: "Tommy Wiseau"}] = movie.actors
      end

      test "returns a transaction's result" do
        result = instrumented(&insert_two_movies_in_transaction/0)

        assert result == {:ok, :done}
        assert Repo.aggregate(Movie, :count) == 2
      end

      test "rolls back a transaction" do
        assert {:error, :rolled_back} = instrumented(&roll_back_insert/0)
        assert Repo.aggregate(Movie, :count) == 0
      end

      test "reraises an error raised in a transaction" do
        assert_raise RuntimeError, "Transaction failed!", fn ->
          instrumented(&raise_in_transaction/0)
        end
      end

      test "returns a stream's rows inside a transaction" do
        insert_movie()

        assert {:ok, [%Movie{title: "The Room"}]} =
                 instrumented(fn ->
                   Repo.transaction(fn -> Enum.to_list(Repo.stream(Movie)) end)
                 end)
      end

      test "returns the changeset for a query that fails on a constraint" do
        Repo.insert!(%Movie{title: "The Room"})

        assert {:error, %Ecto.Changeset{valid?: false}} =
                 instrumented(&insert_duplicate_movie/0)
      end

      test "raises the error for a query that fails with an exception" do
        Repo.insert!(%Movie{title: "The Room"})

        assert_raise Ecto.ConstraintError, fn ->
          instrumented(fn -> Repo.insert!(%Movie{title: "The Room"}) end)
        end
      end

      test "returns the database's error for a query that fails in the database" do
        assert {:error, %Exqlite.Error{}} =
                 instrumented(fn -> Ecto.Adapters.SQL.query(Repo, "SELECT * FROM missing") end)
      end
    end

    describe "the span recorded for a query" do
      test "is a child span named after the repo, with the query as its body" do
        instrumented(fn -> Repo.insert!(%Movie{title: "The Room"}) end)

        assert [root, query] = spans()
        assert query["parent_span_id"] == root["span_id"]
        assert query["name"] == "Query Appsignal.Test.Repo"
        assert category(query) == "query.ecto"

        assert query["attributes"]["appsignal:body"] ==
                 ~s|INSERT INTO "movies" ("title") VALUES (??) RETURNING "id"|

        assert query["error"] == nil
      end

      test "is recorded for each insert, read, update and delete" do
        instrumented(fn ->
          movie = Repo.insert!(%Movie{title: "The Room"})
          Repo.get!(Movie, movie.id)
          Repo.all(Movie)
          movie |> Movie.changeset(%{title: "The Disaster Artist"}) |> Repo.update!()
          Repo.delete!(movie)
        end)

        assert [root | queries] = spans()
        assert Enum.all?(queries, &(&1["parent_span_id"] == root["span_id"]))

        assert Enum.map(queries, & &1["attributes"]["appsignal:body"]) == [
                 ~s|INSERT INTO "movies" ("title") VALUES (??) RETURNING "id"|,
                 ~s|SELECT m0."id", m0."title" FROM "movies" AS m0 WHERE (m0."id" = ?)|,
                 ~s|SELECT m0."id", m0."title" FROM "movies" AS m0|,
                 ~s|UPDATE "movies" SET "title" = ? WHERE ? = ?|,
                 ~s|DELETE FROM "movies" WHERE ? = ?|
               ]
      end

      test "is recorded for each preload query that runs in the caller's process" do
        insert_movie()

        instrumented(fn ->
          Repo.all(from(m in Movie, preload: [:characters, :actors]), in_parallel: false)
          Repo.all(from(m in Movie, preload: [:characters]))
        end)

        assert [root | queries] = spans()
        assert Enum.all?(queries, &(&1["parent_span_id"] == root["span_id"]))

        assert [movies, first, second, movies, characters] = Enum.map(queries, &table/1)
        assert movies == "movies"
        assert characters == "characters"
        assert Enum.sort([first, second]) == ["actors", "characters"]
      end

      test "has no error for a query that fails on a constraint" do
        Repo.insert!(%Movie{title: "The Room"})
        instrumented(&insert_duplicate_movie/0)

        assert [_root, %{"name" => "Query Appsignal.Test.Repo", "error" => nil}] =
                 spans()
      end

      test "has no error for a query that fails with an exception" do
        Repo.insert!(%Movie{title: "The Room"})

        assert_raise Ecto.ConstraintError, fn ->
          instrumented(fn -> Repo.insert!(%Movie{title: "The Room"}) end)
        end

        assert [_root, query] = spans()
        assert query["error"] == nil
      end

      test "has no error for a query that fails in the database" do
        instrumented(fn -> Ecto.Adapters.SQL.query(Repo, "SELECT * FROM missing") end)

        assert [_root, query] = spans()
        assert query["attributes"]["appsignal:body"] == "SELECT * FROM missing"
        assert query["error"] == nil
      end
    end

    describe "the spans recorded for a transaction" do
      test "include a transaction span with the queries and the commit inside it" do
        instrumented(&insert_two_movies_in_transaction/0)

        assert [root, transaction, insert, other_insert, commit] = spans()
        assert other_insert["parent_span_id"] == transaction["span_id"]

        assert transaction["name"] == "Transaction Appsignal.Test.Repo"
        assert category(transaction) == "transaction.ecto"
        assert transaction["parent_span_id"] == root["span_id"]
        assert transaction["attributes"]["appsignal:body"] == nil

        assert insert["name"] == "Query Appsignal.Test.Repo"
        assert insert["parent_span_id"] == transaction["span_id"]

        assert commit["name"] == "Commit Appsignal.Test.Repo"
        assert category(commit) == "commit.ecto"
        assert commit["parent_span_id"] == transaction["span_id"]
        assert commit["attributes"]["appsignal:body"] == nil
      end

      test "leave no span current once the caller's span closes" do
        instrumented(&insert_two_movies_in_transaction/0)
        assert Appsignal.Tracer.current_span() == nil
      end

      test "include a rollback span inside the transaction span, for a rollback" do
        instrumented(&roll_back_insert/0)

        assert [root, transaction, insert, rollback] = spans()
        assert transaction["parent_span_id"] == root["span_id"]
        assert insert["parent_span_id"] == transaction["span_id"]
        assert rollback["name"] == "Rollback Appsignal.Test.Repo"
        assert category(rollback) == "rollback.ecto"
        assert rollback["parent_span_id"] == transaction["span_id"]
      end

      test "include a rollback span, and no error, when the transaction raises" do
        assert_raise RuntimeError, fn -> instrumented(&raise_in_transaction/0) end

        assert [root, transaction, _insert, rollback] = spans()
        assert transaction["parent_span_id"] == root["span_id"]
        assert rollback["name"] == "Rollback Appsignal.Test.Repo"
        assert transaction["error"] == nil
      end

      test "include a nested transaction's queries in the outer transaction span" do
        instrumented(fn ->
          Repo.transaction(fn ->
            Repo.insert!(%Movie{title: "The Room"})
            Repo.transaction(fn -> Repo.insert!(%Movie{title: "The Disaster Artist"}) end)
          end)
        end)

        assert [root, transaction, insert, nested_insert, commit] = spans()
        assert transaction["parent_span_id"] == root["span_id"]

        for span <- [insert, nested_insert, commit] do
          assert span["parent_span_id"] == transaction["span_id"]
        end
      end

      test "include each fetch of a stream as a query" do
        insert_movie()
        instrumented(fn -> Repo.transaction(fn -> Enum.to_list(Repo.stream(Movie)) end) end)

        assert [_root, transaction | queries] = spans()
        assert [_commit | stream_queries] = Enum.reverse(queries)
        assert length(stream_queries) == 3

        for query <- stream_queries do
          assert query["parent_span_id"] == transaction["span_id"]

          assert query["attributes"]["appsignal:body"] ==
                   ~s|SELECT m0."id", m0."title" FROM "movies" AS m0|
        end
      end
    end

    describe "queries that record no span" do
      test "outside an instrumented function" do
        Repo.insert!(%Movie{title: "The Room"})
        Repo.all(Movie)
        Repo.transaction(fn -> Repo.insert!(%Movie{title: "The Disaster Artist"}) end)
        Repo.transaction(fn -> Repo.rollback(:rolled_back) end)

        assert spans() == []
        assert Appsignal.Tracer.current_span() == nil
      end

      test "in a task the instrumented function starts" do
        instrumented(fn -> Task.await(Task.async(fn -> Repo.all(Movie) end)) end)
        assert [%{"name" => "parent"}] = spans()
      end

      test "run in parallel tasks by a preload" do
        insert_movie()
        instrumented(fn -> Repo.all(from(m in Movie, preload: [:characters, :actors])) end)

        assert [_root, query] = spans()
        assert query["attributes"]["appsignal:body"] =~ ~s|FROM "movies"|
      end
    end

    describe "the metrics recorded for a query" do
      setup do
        fake_appsignal = start_supervised!(FakeAppsignal)
        insert_movie()
        [fake_appsignal: fake_appsignal]
      end

      test "are tagged by repo and hostname, and by repo and source", %{
        fake_appsignal: fake_appsignal
      } do
        Repo.all(Movie)

        hostname = %{repo: "Appsignal.Test.Repo", hostname: "Bobs-MBP.example.com"}
        source = %{repo: "Appsignal.Test.Repo", source: "movies"}

        for metric <- ~w(ecto_query_time ecto_decode_time ecto_total_time) do
          assert [%{tags: ^source, value: value}, %{tags: ^hostname, value: value} | _] =
                   FakeAppsignal.get_distribution_values(fake_appsignal, metric)

          assert is_float(value) and value >= 0
        end

        for metric <- ~w(ecto_queue_time ecto_idle_time) do
          assert [%{tags: ^hostname, value: value} | _] =
                   FakeAppsignal.get_distribution_values(fake_appsignal, metric)

          assert is_float(value) and value >= 0
        end
      end

      test "are tagged by hostname only for a query without a source", %{
        fake_appsignal: fake_appsignal
      } do
        Repo.transaction(fn -> :ok end)

        for metric <- ~w(ecto_query_time ecto_total_time) do
          assert [commit, begin | _] =
                   FakeAppsignal.get_distribution_values(fake_appsignal, metric)

          assert Map.keys(commit.tags) == [:hostname, :repo]
          assert Map.keys(begin.tags) == [:hostname, :repo]
        end
      end

      test "are also recorded inside an instrumented function", %{
        fake_appsignal: fake_appsignal
      } do
        start = length(FakeAppsignal.get_distribution_values(fake_appsignal, "ecto_total_time"))
        instrumented(fn -> Repo.all(Movie) end)

        assert length(FakeAppsignal.get_distribution_values(fake_appsignal, "ecto_total_time")) ==
                 start + 2
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to the configured repos' query events" do
        assert attached?(Appsignal.Ecto, [:appsignal, :test, :repo, :query])
      end

      test "attaches to the repos in the :ecto_repos config option with attach/0" do
        on_exit(fn -> :telemetry.detach({Appsignal.Ecto, Database.event(OtherRepo)}) end)

        with_config(%{ecto_repos: [OtherRepo]}, &Appsignal.Ecto.attach/0)
        assert attached?(Appsignal.Ecto, Database.event(OtherRepo))
      end
    end

    describe "attaching the :telemetry handlers to a repo with attach/2" do
      test "records the queries of a repo that is not in the configuration" do
        Database.start(OtherRepo)

        instrumented(fn -> OtherRepo.all(Movie) end)
        assert [_root] = spans()

        Database.attach(OtherRepo)

        instrumented(fn -> OtherRepo.all(Movie) end)
        assert [_first, root, query] = spans()
        assert query["name"] == "Query AppsignalTest.Ecto.OtherRepo"
        assert query["parent_span_id"] == root["span_id"]
      end

      test "logs and returns an error for a repo it is already attached to" do
        log =
          ExUnit.CaptureLog.capture_log(fn ->
            assert {:error, :already_exists} = Appsignal.Ecto.attach(:appsignal, Repo)
          end)

        assert log =~ "Appsignal.Ecto not attached to [:appsignal, :test, :repo, :query]"
      end

      test "follows the telemetry prefix in the repo's application config" do
        Application.put_env(:appsignal, OtherRepo, telemetry_prefix: [:other_repo])
        on_exit(fn -> Application.delete_env(:appsignal, OtherRepo) end)
        Database.start(OtherRepo)

        :ok = Appsignal.Ecto.attach(:appsignal, OtherRepo)
        on_exit(fn -> :telemetry.detach({Appsignal.Ecto, [:other_repo, :query]}) end)

        instrumented(fn -> OtherRepo.all(Movie) end)
        assert [_root, %{"name" => "Query AppsignalTest.Ecto.OtherRepo"}] = spans()
      end

      # Pins current behaviour, not intended behaviour: attach/2 reads the
      # telemetry prefix from the repo's application config only. See
      # https://github.com/appsignal/appsignal-elixir/issues/1076.
      test "misses a telemetry prefix passed when the repo starts" do
        start_supervised!(
          {OtherRepo, database: ":memory:", pool_size: 1, telemetry_prefix: [:other_repo]}
        )

        Database.attach(OtherRepo)

        instrumented(fn -> Ecto.Adapters.SQL.query!(OtherRepo, "SELECT 1") end)
        assert [_root] = spans()
      end
    end

    describe "attaching the :telemetry handlers, with instrument_ecto set to false" do
      @describetag :detaches_handlers

      setup do
        :telemetry.detach({Appsignal.Ecto, [:appsignal, :test, :repo, :query]})

        ExUnit.CaptureLog.capture_log(fn ->
          with_config(%{instrument_ecto: false}, fn -> Appsignal.start([], []) end)
        end)

        :ok
      end

      test "does not attach to the configured repos' query events" do
        refute attached?(Appsignal.Ecto, [:appsignal, :test, :repo, :query])
      end

      test "records no span for a query" do
        instrumented(fn -> Repo.all(Movie) end)
        assert [%{"name" => "parent"}] = spans()
      end
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp insert_two_movies_in_transaction do
      Repo.transaction(fn ->
        Repo.insert!(%Movie{title: "The Room"})
        Repo.insert!(%Movie{title: "The Disaster Artist"})
        :done
      end)
    end

    defp roll_back_insert do
      Repo.transaction(fn ->
        Repo.insert!(%Movie{title: "The Room"})
        Repo.rollback(:rolled_back)
      end)
    end

    defp raise_in_transaction do
      Repo.transaction(fn ->
        Repo.insert!(%Movie{title: "The Room"})
        raise "Transaction failed!"
      end)
    end

    defp insert_duplicate_movie do
      %Movie{} |> Movie.changeset(%{title: "The Room"}) |> Repo.insert()
    end

    defp table(%{"attributes" => %{"appsignal:body" => body}}) do
      [_, table] = Regex.run(~r/ FROM "(\w+)"/, body)
      table
    end

    defp insert_movie do
      Repo.insert!(%Movie{
        title: "The Room",
        characters: [%Character{name: "Tommy"}],
        actors: [%Actor{name: "Tommy Wiseau"}]
      })
    end
  end
end

defmodule Appsignal.Ecto.HandleEventTest do
  use ExUnit.Case
  alias Appsignal.{FakeAppsignal, Test}

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    start_supervised!(Test.Monitor)
    [fake_appsignal: start_supervised!(FakeAppsignal)]
  end

  describe "handle_event/4" do
    test "emits only hostname-tagged distributions for an event without a source", %{
      fake_appsignal: fake_appsignal
    } do
      handle_event(%{query_time: 5_386_000, total_time: 5_386_000}, %{query: "SELECT 1"})

      for metric <- ~w(ecto_query_time ecto_total_time) do
        assert [%{value: 5.386, tags: %{repo: "Appsignal.Test.Repo", hostname: _}}] =
                 FakeAppsignal.get_distribution_values(fake_appsignal, metric)
      end

      for metric <- ~w(ecto_queue_time ecto_decode_time ecto_idle_time) do
        assert FakeAppsignal.get_distribution_values(fake_appsignal, metric) == []
      end
    end

    test "skips measurements that are nil", %{fake_appsignal: fake_appsignal} do
      handle_event(%{query_time: 5_386_000, idle_time: nil, total_time: 8_829_000}, %{
        query: "SELECT 1",
        source: "users"
      })

      assert FakeAppsignal.get_distribution_values(fake_appsignal, "ecto_idle_time") == []
      assert [_, _] = FakeAppsignal.get_distribution_values(fake_appsignal, "ecto_query_time")
    end

    test "does nothing for an event without a total time", %{fake_appsignal: fake_appsignal} do
      handle_event(%{query_time: 5_386_000}, %{query: "SELECT 1"})
      assert FakeAppsignal.get_distribution_values(fake_appsignal, "ecto_query_time") == []
    end
  end

  defp handle_event(measurements, metadata) do
    Appsignal.Ecto.handle_event(
      [:appsignal, :test, :repo, :query],
      measurements,
      Map.put(metadata, :repo, Appsignal.Test.Repo),
      :ok
    )
  end
end
