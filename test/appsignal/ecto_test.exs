defmodule Appsignal.EctoTest do
  use ExUnit.Case
  alias Appsignal.{Ecto, Test, Span}

  test "is attached to the repo query event automatically" do
    assert attached?([:appsignal, :test, :repo, :query])
  end

  test "attach/2 attaches to events with custom prefixes" do
    Application.put_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: [:my_repo])
    Ecto.attach(:appsignal, Appsignal.Test.Repo)

    assert attached?([:my_repo, :query])

    Application.delete_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: :my_repo)
  end

  describe "query/4" do
    setup do
      Test.Nif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

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

    test "creates a span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Query Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert {:ok, [{%Span{}, "appsignal:category", "ecto.query"}]} =
               Test.Span.get(:set_attribute)
    end
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Ecto, event}
    end)
  end
end
