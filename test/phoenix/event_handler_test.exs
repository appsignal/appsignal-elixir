defmodule Appsignal.Phoenix.EventHandlerTest do
  use ExUnit.Case, async: true
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()

    [fake_transaction: fake_transaction]
  end

  describe "after receiving a router_dispatch-start event" do
    setup [:start_transaction, :router_dispatch_start_event]

    test "keeps the handler attached" do
      assert router_dispatch_event_handler_attached?()
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExampleWeb.PageController#index" ==
               FakeTransaction.action(fake_transaction)
    end
  end

  describe "after receiving a router_dispatch-start event with non-atom opts" do
    setup [:start_transaction]

    setup do: do_router_dispatch_start_event(%Plug.Conn{}, atom?: false)

    test "keeps the handler attached" do
      assert router_dispatch_event_handler_attached?()
    end

    test "does not set the transaction's action name", %{fake_transaction: fake_transaction} do
      assert nil == FakeTransaction.action(fake_transaction)
    end
  end

  describe "after receiving a router_dispatch-start event with a transaction in the conn" do
    setup [:start_transaction, :router_dispatch_start_event_with_transaction_in_conn]

    test "keeps the handler attached" do
      assert router_dispatch_event_handler_attached?()
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExampleWeb.PageController#index" ==
               FakeTransaction.action(fake_transaction)
    end
  end

  describe "after receiving an endpoint-start event" do
    setup [:start_transaction, :endpoint_start_event]

    test "starts an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.started_events(fake_transaction) == [transaction]
    end
  end

  describe "after receiving an endpoint-start event with a transaction in the conn" do
    setup [:endpoint_start_event_with_transaction_in_conn]

    test "starts an event", %{fake_transaction: fake_transaction, transaction: transaction} do
      assert FakeTransaction.started_events(fake_transaction) == [transaction]
    end
  end

  describe "after receiving an endpoint-start and an endpoint-stop event" do
    setup [:start_transaction, :endpoint_start_event, :endpoint_finish_event]

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
    setup [:endpoint_finish_event_with_transaction_in_conn]

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

  defp router_dispatch_start_event(_), do: do_router_dispatch_start_event()

  defp router_dispatch_start_event_with_transaction_in_conn(_) do
    transaction = %Appsignal.Transaction{}

    %Plug.Conn{}
    |> Plug.Conn.put_private(:appsignal_transaction, transaction)
    |> do_router_dispatch_start_event()

    [transaction: transaction]
  end

  defp do_router_dispatch_start_event(conn \\ %Plug.Conn{}, plug_opts \\ :index) do
    :telemetry.execute(
      [:phoenix, :router_dispatch, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: conn,
        log: :debug,
        path_params: %{},
        pipe_through: [:browser],
        plug: AppsignalPhoenixExampleWeb.PageController,
        plug_opts: plug_opts,
        route: "/"
      }
    )
  end

  defp endpoint_start_event_with_transaction_in_conn(_) do
    transaction = %Appsignal.Transaction{}

    %Plug.Conn{}
    |> Plug.Conn.put_private(:appsignal_transaction, transaction)
    |> do_endpoint_start_event()

    [transaction: transaction]
  end

  defp endpoint_start_event(_), do: do_endpoint_start_event()

  defp do_endpoint_start_event(conn \\ %Plug.Conn{}) do
    :telemetry.execute(
      [:phoenix, :endpoint, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: conn,
        options: []
      }
    )
  end

  defp endpoint_finish_event_with_transaction_in_conn(_) do
    transaction = %Appsignal.Transaction{}

    %Plug.Conn{}
    |> Plug.Conn.put_private(:appsignal_transaction, transaction)
    |> do_endpoint_finish_event()

    [transaction: transaction]
  end

  defp endpoint_finish_event(_), do: do_endpoint_finish_event()

  defp do_endpoint_finish_event(conn \\ %Plug.Conn{}) do
    :telemetry.execute(
      [:phoenix, :endpoint, :stop],
      %{duration: 49_474_000},
      %{
        conn: conn,
        options: []
      }
    )
  end

  defp router_dispatch_event_handler_attached? do
    [:phoenix, :router_dispatch, :start]
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == "appsignal_phoenix_event_handler"
    end)
  end
end
