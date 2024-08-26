defmodule Appsignal.EctoTest do
  use ExUnit.Case
  alias Appsignal.{Ecto, Span, Test}
  import AppsignalTest.Utils, only: [with_config: 2]

  test "is attached to the repo query event automatically" do
    assert attached?([:appsignal, :test, :repo, :query])
  end

  test "is not attached automatically when :instrument_ecto is set to false" do
    :telemetry.detach({Ecto, [:appsignal, :test, :repo, :query]})

    with_config(%{instrument_ecto: false}, fn -> Appsignal.start([], []) end)

    assert !attached?([:appsignal, :test, :repo, :query])

    :ok = Ecto.attach()
  end

  test "attach/0 attaches to configured repos" do
    assert with_config(
             %{ecto_repos: [Appsignal.Test.RepoOne, Appsignal.Test.RepoTwo]},
             &Ecto.attach/0
           )

    assert attached?([:appsignal, :test, :repo_one, :query])
    assert attached?([:appsignal, :test, :repo_two, :query])
  end

  test "attach/2 attaches to events with custom prefixes" do
    Application.put_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: [:my_repo])
    Ecto.attach(:appsignal, Appsignal.Test.Repo)

    assert attached?([:my_repo, :query])

    Application.delete_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: :my_repo)
  end

  describe "handle_event/4, without a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query:
            "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/4 and handle_query/4, with a root span from the tracer" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query:
            "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Query Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "query.ecto")
    end

    test "sets the span's body" do
      assert {:ok,
              [
                {%Span{},
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0"}
              ]} = Test.Span.get(:set_sql)
    end

    test "closes the span with an end time" do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)
      {:ok, [{%Span{}, end_time: end_time}]} = Test.Tracer.get(:close_span)
      assert end_time - start_time == 8_829_000
    end
  end

  describe "handle_event/4 and handle_query/4, with a root span passed via telemetry options" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      span =
        fn -> Appsignal.Tracer.create_span("http_request") end
        |> Task.async()
        |> Task.await()

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query:
            "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query,
          options: [
            _appsignal_current_span: span
          ]
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Query Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "query.ecto")
    end

    test "sets the span's body" do
      assert {:ok,
              [
                {%Span{},
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0"}
              ]} = Test.Span.get(:set_sql)
    end

    test "closes the span with an end time" do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)
      {:ok, [{%Span{}, end_time: end_time}]} = Test.Tracer.get(:close_span)
      assert end_time - start_time == 8_829_000
    end
  end

  describe "handle_event/4 and handle_commit/4, with a root span from the tracer and a root span passed via telemetry options" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      telemetry_span =
        fn -> Appsignal.Tracer.create_span("http_request") end
        |> Task.async()
        |> Task.await()

      tracer_span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query: "commit",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{telemetry_span: telemetry_span, tracer_span: tracer_span}
    end

    test "creates a span with the tracer span as the parent and a start time", %{
      tracer_span: parent
    } do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Commit Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "commit.ecto")
    end

    test "does not set the span's body" do
      assert Test.Span.get(:set_sql) == :error
    end

    test "closes the span and the parent tracer span with an end time", %{tracer_span: parent} do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)

      {:ok, [{^parent, end_time: end_time}, {%Span{}, end_time: end_time}]} =
        Test.Tracer.get(:close_span)

      assert end_time - start_time == 8_829_000
    end
  end

  describe "handle_begin/4, with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query: "begin",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Transaction Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "transaction.ecto")
    end

    test "does not set the span's body" do
      assert Test.Span.get(:set_sql) == :error
    end

    test "does not close the span" do
      assert Test.Tracer.get(:close_span) == :error
    end
  end

  describe "handle_commit/4, with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query: "commit",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Commit Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "commit.ecto")
    end

    test "does not set the span's body" do
      assert Test.Span.get(:set_sql) == :error
    end

    test "closes the span and its parent with an end time", %{parent: parent} do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)

      {:ok, [{^parent, end_time: end_time}, {%Span{}, end_time: end_time}]} =
        Test.Tracer.get(:close_span)

      assert end_time - start_time == 8_829_000
    end
  end

  describe "handle_rollback/4, with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:appsignal, :test, :repo, :query],
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query: "rollback",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Rollback Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "rollback.ecto")
    end

    test "does not set the span's body" do
      assert Test.Span.get(:set_sql) == :error
    end

    test "closes the span and its parent with an end time", %{parent: parent} do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)

      {:ok, [{^parent, end_time: end_time}, {%Span{}, end_time: end_time}]} =
        Test.Tracer.get(:close_span)

      assert end_time - start_time == 8_829_000
    end
  end

  describe "handle_event/4, when attaching the handler from outside the Ecto module" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      event = [:appsignal, :test, :repo, :outside]
      :telemetry.attach({__MODULE__, event}, event, &Appsignal.Ecto.handle_event/4, :ok)

      span = Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        event,
        %{
          decode_time: 2_204_000,
          query_time: 5_386_000,
          queue_time: 1_239_000,
          total_time: 8_829_000
        },
        %{
          params: [],
          query:
            "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
          repo: Appsignal.Test.Repo,
          result: :ok,
          source: "users",
          type: :ecto_sql_query
        }
      )

      %{parent: span}
    end

    test "creates a span with a parent and a start time", %{parent: parent} do
      {:ok, [{"http_request", ^parent, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Query Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "query.ecto")
    end

    test "sets the span's body" do
      assert {:ok,
              [
                {%Span{},
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0"}
              ]} = Test.Span.get(:set_sql)
    end

    test "closes the span with an end time" do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)
      {:ok, [{%Span{}, end_time: end_time}]} = Test.Tracer.get(:close_span)
      assert end_time - start_time == 8_829_000
    end
  end

  defp attribute(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Ecto, event}
    end)
  end
end
