defmodule Appsignal.Phoenix.EventHandlerTest do
  use ExUnit.Case, async: true
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()

    [fake_transaction: fake_transaction]
  end

  describe "after receiving an endpoint-start event" do
    setup [:start_transaction, :start_event]

    test "starts an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.started_events(fake_transaction) == [transaction]
    end
  end

  describe "after receiving an endpoint-start event with a transaction in the conn" do
    setup [:start_event_with_transaction_in_conn]

    test "starts an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.started_events(fake_transaction) == [transaction]
    end
  end

  describe "after receiving an endpoint-start and an endpoint-stop event" do
    setup [:start_transaction, :start_event, :finish_event]

    test "finishes an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.finished_events(fake_transaction) == [
               %{
                 body: %{},
                 body_format: 0,
                 name: "call.phoenix_endpoint",
                 title: "call.phoenix_endpoint",
                 transaction: transaction
               }
             ]
    end
  end

  describe "after receiving an endpoint-stop event with a transaction in the conn" do
    setup [:finish_event_with_transaction_in_conn]

    test "finishes an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.finished_events(fake_transaction) == [
               %{
                 body: %{},
                 body_format: 0,
                 name: "call.phoenix_endpoint",
                 title: "call.phoenix_endpoint",
                 transaction: transaction
               }
             ]
    end
  end

  defp start_transaction(_) do
    [transaction: Appsignal.Transaction.start("test", :http_request)]
  end

  defp start_event_with_transaction_in_conn(_) do
    transaction = %Appsignal.Transaction{}

    %Plug.Conn{}
    |> Plug.Conn.put_private(:appsignal_transaction, transaction)
    |> do_start_event()

    [transaction: transaction]
  end

  defp start_event(_), do: do_start_event()

  defp do_start_event(conn \\ %Plug.Conn{}) do
    :telemetry.execute(
      [:phoenix, :endpoint, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: conn,
        options: []
      }
    )
  end

  defp finish_event_with_transaction_in_conn(_) do
    transaction = %Appsignal.Transaction{}

    %Plug.Conn{}
    |> Plug.Conn.put_private(:appsignal_transaction, transaction)
    |> do_finish_event()

    [transaction: transaction]
  end

  defp finish_event(_), do: do_finish_event()

  defp do_finish_event(conn \\ %Plug.Conn{}) do
    :telemetry.execute(
      [:phoenix, :endpoint, :stop],
      %{duration: 49_474_000},
      %{
        conn: conn,
        options: []
      }
    )
  end
end
