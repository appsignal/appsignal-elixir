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

  describe "after receiving an endpoint-start and an endpoint-stop event" do
    setup [:start_transaction, :start_event, :finish_event]

    test "finishes an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.finished_events(fake_transaction) == [
               %{
                 body: nil,
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

  defp start_event(_) do
    :telemetry.execute(
      [:phoenix, :endpoint, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: %Plug.Conn{},
        options: []
      }
    )
  end

  defp finish_event(_) do
    :telemetry.execute(
      [:phoenix, :endpoint, :stop],
      %{duration: 49_474_000},
      %{
        conn: %Plug.Conn{},
        options: []
      }
    )
  end
end
