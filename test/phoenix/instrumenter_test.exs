defmodule Appsignal.Phoenix.InstrumenterTest do
  use ExUnit.Case, async: true
  alias Appsignal.{Phoenix.Instrumenter, Transaction, FakeTransaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link

    transaction = Transaction.start("test", :http_request)
    conn = %Plug.Conn{}
    |> Plug.Conn.put_private(:phoenix_controller, "foo")
    |> Plug.Conn.put_private(:phoenix_action, "bar")

    [transaction: transaction, conn: conn, fake_transaction: fake_transaction]
  end

  test "starts an event in phoenix_controller_call", %{transaction: transaction, conn: conn} do
    arguments = %{conn: conn}

    assert {transaction, arguments} ==
      Instrumenter.phoenix_controller_call(:start, nil, arguments)
  end

  test "starts an event in phoenix_controller_render", context do
    arguments = %{foo: "bar"}
    assert {context[:transaction], arguments} ==
      Instrumenter.phoenix_controller_render(:start, nil, arguments)
  end

  test "finishes an event in phoenix_controller_call", %{transaction: transaction, fake_transaction: fake_transaction} do
    Instrumenter.phoenix_controller_call(:stop, nil, {transaction, %{conn: %Plug.Conn{}}})
    assert [
      %{
        transaction: transaction,
        name: "call.phoenix_controller",
        title: "call.phoenix_controller",
        body: %{},
        body_format: 0
      }
    ] == FakeTransaction.finished_events(fake_transaction)
  end

  test "does not finish an event in phoenix_controller_call without a transaction or conn", %{fake_transaction: fake_transaction} do
    Instrumenter.phoenix_controller_call(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events(fake_transaction)
  end

  test "finishes an event in phoenix_controller_render", %{transaction: transaction, fake_transaction: fake_transaction} do
    Instrumenter.phoenix_controller_render(:stop, nil, {transaction, %{conn: %Plug.Conn{}}})
    assert [
      %{
        transaction: transaction,
        name: "render.phoenix_controller",
        title: "render.phoenix_controller",
        body: %{},
        body_format: 0
      }
    ] == FakeTransaction.finished_events(fake_transaction)
  end

  test "does not finish an event in phoenix_controller_render without a transaction", %{fake_transaction: fake_transaction} do
    Instrumenter.phoenix_controller_render(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events(fake_transaction)
  end
end
