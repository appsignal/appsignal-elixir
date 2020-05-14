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

    test "creates a span with a start time" do
      {:ok, [{"http_request", nil, start_time: time}]} = Test.Tracer.get(:create_span)
      assert is_integer(time)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Query Appsignal.Test.Repo"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "ecto.query")
    end

    test "sets the span's body" do
      assert attribute(
               "appsignal:body",
               "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0"
             )
    end

    test "closes the span with an end time" do
      {:ok, [{_, _, start_time: start_time}]} = Test.Tracer.get(:create_span)
      {:ok, [{%Span{}, end_time: end_time}]} = Test.Tracer.get(:close_span)
      assert end_time - start_time == 8_829_000
    end
  end

  describe "query/4, for a query without a source" do
    setup do
      Test.Nif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

      :telemetry.execute([:appsignal, :test, :repo, :query], %{}, %{source: nil})
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
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
