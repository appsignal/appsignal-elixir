defmodule AppsignalHelpersTest do
  use ExUnit.Case, async: false
  alias Appsignal.{FakeTransaction, Instrumentation.Helpers}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "instrument with transaction", %{fake_transaction: fake_transaction} do
    transaction = FakeTransaction.start("123", :http_request)
    call_instrument(transaction)

    assert [^transaction] = FakeTransaction.started_events(fake_transaction)

    assert [%{body: "", body_format: 0, name: "name", title: "title", transaction: ^transaction}] =
             FakeTransaction.finished_events(fake_transaction)
  end

  test "instrument with pid", %{fake_transaction: fake_transaction} do
    transaction = FakeTransaction.start("bar", :http_request)
    call_instrument(self())
    assert [^transaction] = FakeTransaction.started_events(fake_transaction)

    assert [%{body: "", body_format: 0, name: "name", title: "title", transaction: ^transaction}] =
             FakeTransaction.finished_events(fake_transaction)
  end

  test "instrument with nil", %{fake_transaction: fake_transaction} do
    call_instrument(nil)

    assert FakeTransaction.finished_events(fake_transaction) == []
  end

  test "instrument on an ignored process", %{fake_transaction: fake_transaction} do
    call_instrument(:ignored)

    assert FakeTransaction.finished_events(fake_transaction) == []
  end

  defp call_instrument(arg) do
    r =
      Helpers.instrument(arg, "name", "title", fn ->
        :timer.sleep(100)
        :result
      end)

    assert :result == r
  end
end
