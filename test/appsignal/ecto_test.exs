defmodule Appsignal.EctoTest do
  use ExUnit.Case
  alias Appsignal.{FakeTransaction, Transaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    {:ok, fake_transaction: fake_transaction}
  end

  test "records an event", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("test", :http_request)

    perform_event()

    assert [
             %{
               transaction: ^transaction,
               body:
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
               body_format: 1,
               duration: 8_829_000,
               name: "query.ecto",
               title: ""
             }
           ] = FakeTransaction.recorded_events(fake_transaction)
  end

  test "records an event from Telemetry 0.3.x", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("test", :http_request)

    perform_telemetry_0_3_event()

    assert [
             %{
               transaction: ^transaction,
               body:
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
               body_format: 1,
               duration: 58_336_000,
               name: "query.ecto",
               title: ""
             }
           ] = FakeTransaction.recorded_events(fake_transaction)
  end

  test "records an event from the Ecto logger", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("test", :http_request)

    log_event()

    assert [
             %{
               transaction: ^transaction,
               body:
                 "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
               body_format: 1,
               duration: 58_336_000,
               name: "query.ecto",
               title: ""
             }
           ] = FakeTransaction.recorded_events(fake_transaction)
  end

  test "does not record an event without a Transaction", %{fake_transaction: fake_transaction} do
    perform_event()
    perform_telemetry_0_3_event()

    assert [] == FakeTransaction.recorded_events(fake_transaction)
  end

  defp perform_event do
    Appsignal.Ecto.handle_event(
      [:appsignal_phoenix_example, :repo, :query],
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
        repo: AppsignalPhoenixExample.Repo,
        result: :ok,
        source: "users",
        type: :ecto_sql_query
      },
      nil
    )
  end

  defp perform_telemetry_0_3_event do
    Appsignal.Ecto.handle_event(
      [:appsignal_phoenix_example, :repo, :query],
      58_336_000,
      %{
        decode_time: 22_943_000,
        params: [],
        query:
          "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
        query_time: 33_874_000,
        queue_time: 1_519_000,
        result:
          {:ok,
           %{
             columns: ["id", "name", "inserted_at", "updated_at"],
             command: :select,
             connection_id: 66958,
             messages: [],
             num_rows: 1,
             rows: [
               [1, "Testing!", ~N[2019-01-10 13:38:27.000000], ~N[2019-01-23 11:42:44.000000]]
             ]
           }},
        source: "users"
      },
      nil
    )
  end

  defp log_event do
    Appsignal.Ecto.log(%{
      decode_time: 22_943_000,
      params: [],
      query:
        "SELECT u0.\"id\", u0.\"name\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0",
      query_time: 33_874_000,
      queue_time: 1_519_000,
      result:
        {:ok,
         %{
           columns: ["id", "name", "inserted_at", "updated_at"],
           command: :select,
           connection_id: 66958,
           messages: [],
           num_rows: 1,
           rows: [
             [1, "Testing!", ~N[2019-01-10 13:38:27.000000], ~N[2019-01-23 11:42:44.000000]]
           ]
         }},
      source: "users"
    })
  end
end
