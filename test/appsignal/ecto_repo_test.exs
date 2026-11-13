if Appsignal.Dependencies.present?(:ecto_sql) do
  defmodule AppsignalTest.Ecto.OverridingRepo do
    use Appsignal.Ecto.Repo, otp_app: :appsignal, adapter: Ecto.Adapters.SQLite3

    def default_options(operation) do
      super(operation) ++ [stacktrace: true]
    end
  end

  defmodule AppsignalTest.Ecto.ReplacingRepo do
    use Appsignal.Ecto.Repo, otp_app: :appsignal, adapter: Ecto.Adapters.SQLite3

    def default_options(_operation) do
      [stacktrace: true]
    end
  end

  defmodule Appsignal.Ecto.RepoTest do
    use AppsignalTest.IntegrationCase
    import Ecto.Query
    alias Appsignal.Test.Repo
    alias AppsignalTest.Ecto.{Actor, AppsignalRepo, Character, Database, Movie}
    alias AppsignalTest.Ecto.{OverridingRepo, ReplacingRepo}

    setup do
      Database.start(Repo)
      AppsignalRepo |> Database.start() |> Database.attach()
      :ok
    end

    describe "running queries, compared with a repo without Appsignal.Ecto.Repo" do
      test "returns the same for inserts, reads, updates and deletes" do
        assert same_results(fn repo ->
                 movie = repo.insert!(%Movie{title: "The Room"})

                 [
                   movie,
                   repo.get(Movie, movie.id),
                   repo.all(Movie),
                   repo.update(Movie.changeset(movie, %{title: "The Disaster Artist"})),
                   repo.delete(movie),
                   repo.all(Movie)
                 ]
               end)
      end

      test "returns the same for preloads" do
        assert same_results(fn repo ->
                 insert_movie(repo)

                 [
                   repo.all(from(m in Movie, preload: [:characters, :actors])),
                   repo.preload(repo.all(Movie), [:characters, :actors])
                 ]
               end)
      end

      test "returns the same for transactions and streams" do
        assert same_results(fn repo ->
                 insert_movie(repo)

                 [
                   repo.transaction(fn -> Enum.to_list(repo.stream(Movie)) end),
                   repo.transaction(fn -> repo.rollback(:rolled_back) end)
                 ]
               end)
      end

      test "raises the same errors" do
        assert same_results(fn repo ->
                 repo.insert!(%Movie{title: "The Room"})

                 assert_raise Ecto.ConstraintError, fn ->
                   repo.insert!(%Movie{title: "The Room"})
                 end
               end)
      end

      test "returns the same invalid changeset, except for the options it carries" do
        insert = fn repo ->
          repo.insert!(%Movie{title: "The Room"})

          instrumented(fn ->
            %Movie{} |> Movie.changeset(%{title: "The Room"}) |> repo.insert()
          end)
        end

        assert {:error, %Ecto.Changeset{repo: Repo, repo_opts: []} = changeset} = insert.(Repo)

        assert {:error, %Ecto.Changeset{repo: AppsignalRepo} = appsignal_changeset} =
                 insert.(AppsignalRepo)

        assert [telemetry_options: [_appsignal_current_span: %Appsignal.Span{}]] =
                 appsignal_changeset.repo_opts

        assert %{appsignal_changeset | repo: Repo, repo_opts: []} == changeset
      end

      test "preloads associations from parallel tasks" do
        insert_movie(AppsignalRepo)

        [movie] =
          instrumented(fn ->
            AppsignalRepo.all(from(m in Movie, preload: [:characters, :actors]))
          end)

        assert [%Character{name: "Tommy"}] = movie.characters
        assert [%Actor{name: "Tommy Wiseau"}] = movie.actors
      end
    end

    describe "the spans recorded for a query" do
      test "include a preload's queries from parallel tasks, as children of the caller's span" do
        insert_movie(AppsignalRepo)

        instrumented(fn ->
          AppsignalRepo.all(from(m in Movie, preload: [:characters, :actors]))
        end)

        assert [root | queries] = spans()
        assert Enum.all?(queries, &(&1["parent_span_id"] == root["span_id"]))
        assert Enum.all?(queries, &(&1["name"] == "Query AppsignalTest.Ecto.AppsignalRepo"))
        assert queries |> Enum.map(&table/1) |> Enum.sort() == ["actors", "characters", "movies"]
      end

      test "include a transaction's commit inside the transaction span, not under the caller's" do
        instrumented(fn ->
          AppsignalRepo.transaction(fn -> AppsignalRepo.all(Movie) end)
        end)

        assert [root, transaction, query, commit] = spans()
        assert transaction["parent_span_id"] == root["span_id"]
        assert query["parent_span_id"] == transaction["span_id"]
        assert commit["parent_span_id"] == transaction["span_id"]
      end
    end

    describe "queries that record no span" do
      test "run in parallel tasks by a preload that passes its own telemetry options" do
        insert_movie(AppsignalRepo)

        instrumented(fn ->
          AppsignalRepo.all(from(m in Movie, preload: [:characters, :actors]),
            telemetry_options: [customer: true]
          )
        end)

        assert [_root, query] = spans()
        assert table(query) == "movies"
      end

      test "in a task the instrumented function starts" do
        instrumented(fn -> Task.await(Task.async(fn -> AppsignalRepo.all(Movie) end)) end)
        assert [%{"name" => "parent"}] = spans()
      end
    end

    describe "default_options/1" do
      test "passes the current span in the telemetry options" do
        assert AppsignalRepo.default_options(:all) == [
                 telemetry_options: [_appsignal_current_span: nil]
               ]

        instrumented(fn ->
          assert AppsignalRepo.default_options(:all) == [
                   telemetry_options: [_appsignal_current_span: Appsignal.Tracer.current_span()]
                 ]
        end)
      end
    end

    describe "a repo whose default_options/1 override calls super" do
      setup do
        OverridingRepo |> Database.start() |> Database.attach()
        insert_movie(OverridingRepo)
        :ok
      end

      test "applies the repo's own options and AppSignal's" do
        metadata = capture_metadata(OverridingRepo, fn -> OverridingRepo.all(Movie) end)
        assert is_list(metadata.stacktrace)
        assert metadata.options == [_appsignal_current_span: nil]
      end

      test "records a preload's queries from parallel tasks as children of the caller's span" do
        instrumented(fn ->
          OverridingRepo.all(from(m in Movie, preload: [:characters, :actors]))
        end)

        assert [root | queries] = spans()
        assert length(queries) == 3
        assert Enum.all?(queries, &(&1["parent_span_id"] == root["span_id"]))
      end
    end

    describe "a repo whose default_options/1 override does not call super" do
      setup do
        ReplacingRepo |> Database.start() |> Database.attach()
        insert_movie(ReplacingRepo)
        :ok
      end

      test "applies the repo's own options but not AppSignal's" do
        metadata = capture_metadata(ReplacingRepo, fn -> ReplacingRepo.all(Movie) end)
        assert is_list(metadata.stacktrace)
        assert metadata.options == []
      end

      test "records no span for a preload's queries from parallel tasks" do
        instrumented(fn ->
          ReplacingRepo.all(from(m in Movie, preload: [:characters, :actors]))
        end)

        assert [_root, query] = spans()
        assert table(query) == "movies"
      end
    end

    defp same_results(fun) do
      assert fun.(Repo) == fun.(AppsignalRepo)
      true
    end

    defp capture_metadata(repo, fun) do
      id = {__MODULE__, :capture_metadata}
      test = self()

      :telemetry.attach(
        id,
        Database.event(repo),
        fn _event, _measurements, metadata, _config -> send(test, {:metadata, metadata}) end,
        nil
      )

      try do
        fun.()
      after
        :telemetry.detach(id)
      end

      assert_received {:metadata, metadata}
      metadata
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp insert_movie(repo) do
      repo.insert!(%Movie{
        title: "The Room",
        characters: [%Character{name: "Tommy"}],
        actors: [%Actor{name: "Tommy Wiseau"}]
      })
    end

    defp table(%{"attributes" => %{"appsignal:body" => body}}) do
      [_, table] = Regex.run(~r/ FROM "(\w+)"/, body)
      table
    end
  end
end
