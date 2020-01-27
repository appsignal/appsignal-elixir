defmodule Appsignal.Phoenix.InstrumenterTest do
  use ExUnit.Case, async: true
  alias Appsignal.{FakeTransaction, Phoenix.Instrumenter, Transaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()

    conn =
      %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, "foo")
      |> Plug.Conn.put_private(:phoenix_action, "bar")

    [conn: conn, fake_transaction: fake_transaction]
  end

  test "starts an event in phoenix_controller_call", %{
    conn: conn,
    fake_transaction: fake_transaction
  } do
    transaction = Transaction.start("test", :http_request)

    assert {^transaction, %{conn: _}} =
             Instrumenter.phoenix_controller_call(:start, nil, %{conn: conn})

    assert [^transaction] = FakeTransaction.started_events(fake_transaction)
  end

  test "sets the action name in phoenix_controller_call", %{
    conn: conn,
    fake_transaction: fake_transaction
  } do
    transaction = Transaction.start("test", :http_request)
    arguments = %{conn: conn, transaction: transaction}

    Instrumenter.phoenix_controller_call(:start, nil, arguments)
    assert "foo#bar" == FakeTransaction.action(fake_transaction)
  end

  test "does not start an event in phoenix_controller_call without a transaction", %{
    conn: conn,
    fake_transaction: fake_transaction
  } do
    arguments = %{conn: conn}

    assert nil == Instrumenter.phoenix_controller_call(:start, nil, arguments)
    assert [] == FakeTransaction.started_events(fake_transaction)
  end

  test "starts an event in phoenix_controller_render", %{
    conn: conn,
    fake_transaction: fake_transaction
  } do
    transaction = Transaction.start("test", :http_request)

    assert {^transaction, %{conn: _}} =
             Instrumenter.phoenix_controller_call(:start, nil, %{conn: conn})

    assert [^transaction] = FakeTransaction.started_events(fake_transaction)
  end

  test "does not start an event in phoenix_controller_render without a transaction", %{
    conn: conn,
    fake_transaction: fake_transaction
  } do
    arguments = %{conn: conn}

    assert nil == Instrumenter.phoenix_controller_render(:start, nil, arguments)
    assert [] == FakeTransaction.started_events(fake_transaction)
  end

  test "finishes an event in phoenix_controller_call", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("test", :http_request)
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

  test "does not finish an event in phoenix_controller_call without a transaction or conn", %{
    fake_transaction: fake_transaction
  } do
    Instrumenter.phoenix_controller_call(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events(fake_transaction)
  end

  test "finishes an event in phoenix_controller_render", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("test", :http_request)
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

  test "does not finish an event in phoenix_controller_render without a transaction", %{
    fake_transaction: fake_transaction
  } do
    Instrumenter.phoenix_controller_render(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events(fake_transaction)
  end
end
