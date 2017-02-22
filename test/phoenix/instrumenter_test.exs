defmodule Appsignal.Phoenix.InstrumenterTest do
  use ExUnit.Case, async: true
  alias Appsignal.{Phoenix.Instrumenter, Transaction, FakeTransaction}

  setup do
    FakeTransaction.start_link

    transaction = Transaction.start("test", :http_request)

    conn = %Plug.Conn{}
    |> Plug.Conn.put_private(:phoenix_controller, "foo")
    |> Plug.Conn.put_private(:phoenix_action, "bar")

    [transaction: transaction, conn: conn]
  end

  test "starts an event in phoenix_controller_call", context do
    arguments = %{foo: "bar"}
    assert {context[:transaction], arguments} ==
      Instrumenter.phoenix_controller_call(:start, nil, arguments)
  end

  test "starts an event in phoenix_controller_render", context do
    arguments = %{foo: "bar"}
    assert {context[:transaction], arguments} ==
      Instrumenter.phoenix_controller_render(:start, nil, arguments)
  end

  test "finishes an event in phoenix_controller_call", context do
    Instrumenter.phoenix_controller_call(:stop, nil, {context[:transaction], %{conn: context[:conn]}})
    assert [
      %{
        transaction: context[:transaction],
        name: "call.phoenix_controller",
        title: "call.phoenix_controller",
        body: %{},
        body_format: 0
      }
    ] == FakeTransaction.finished_events
  end

  test "does not finish an event in phoenix_controller_call without a transaction or conn" do
    Instrumenter.phoenix_controller_call(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events
  end

  test "finishes an event in phoenix_controller_render", context do
    Instrumenter.phoenix_controller_render(:stop, nil, {context[:transaction], %{conn: context[:conn]}})
    assert [
      %{
        transaction: context[:transaction],
        name: "render.phoenix_controller",
        title: "render.phoenix_controller",
        body: %{},
        body_format: 0
      }
    ] == FakeTransaction.finished_events
  end

  test "does not finish an event in phoenix_controller_render without a transaction" do
    Instrumenter.phoenix_controller_render(:stop, nil, nil)
    assert [] == FakeTransaction.finished_events
  end
end
