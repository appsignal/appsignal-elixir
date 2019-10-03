defmodule UsingAppsignalDecorators do
  use Appsignal.Instrumentation.Decorators

  @decorate transaction()
  def transaction do
    bar(123)
  end

  @decorate transaction(:background_job)
  def background_transaction do
    bar(123)
  end

  @decorate transaction()
  def transaction_with_return_value(x) do
    2 * x
  end

  @decorate transaction_event()
  def bar(arg) do
    nested(arg, arg)
  end

  @doc "A moduledoc attribute"
  @decorate transaction_event()
  def nested(_arg1, _arg2) do
  end
end

defmodule UsingAppsignalDecoratorsWithCustomNamespaces do
  use Appsignal.Instrumentation.Decorators

  @doc "A moduledoc attribute"
  @decorate transaction_event(:http)
  def bar(arg) do
    nested(arg, arg)
  end

  @decorate transaction_event(:db)
  def nested(_arg1, _arg2) do
  end
end

defmodule Appsignal.Instrumentation.DecoratorsTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "instrument transaction with event", %{fake_transaction: fake_transaction} do
    UsingAppsignalDecorators.transaction()

    assert [{"123", :http_request}] = FakeTransaction.started_transactions(fake_transaction)

    assert [
             %{title: "Elixir.UsingAppsignalDecorators.bar"},
             %{title: "Elixir.UsingAppsignalDecorators.nested"}
           ] = FakeTransaction.finished_events(fake_transaction)
  end

  test "instrument module function", %{fake_transaction: fake_transaction} do
    transaction = FakeTransaction.start("123", :http_request)
    UsingAppsignalDecorators.bar(123)
    assert [^transaction, ^transaction] = FakeTransaction.started_events(fake_transaction)

    assert [
             %{
               body: "",
               body_format: 0,
               name: "bar",
               title: "Elixir.UsingAppsignalDecorators.bar",
               transaction: ^transaction
             },
             %{
               body: "",
               body_format: 0,
               name: "nested",
               title: "Elixir.UsingAppsignalDecorators.nested",
               transaction: ^transaction
             }
           ] = FakeTransaction.finished_events(fake_transaction)
  end

  test "instrument transaction", %{fake_transaction: fake_transaction} do
    UsingAppsignalDecorators.transaction()
    assert [{"123", :http_request}] = FakeTransaction.started_transactions(fake_transaction)

    assert "Elixir.UsingAppsignalDecorators#transaction" =
             FakeTransaction.action(fake_transaction)

    assert [transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "instrument background transaction", %{fake_transaction: fake_transaction} do
    UsingAppsignalDecorators.background_transaction()
    assert [{"123", :background_job}] = FakeTransaction.started_transactions(fake_transaction)

    assert "Elixir.UsingAppsignalDecorators#background_transaction" =
             FakeTransaction.action(fake_transaction)

    assert [transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "instrument transaction with return value", %{fake_transaction: fake_transaction} do
    result = UsingAppsignalDecorators.transaction_with_return_value(123)
    assert 246 == result
    assert [{"123", :http_request}] = FakeTransaction.started_transactions(fake_transaction)

    assert "Elixir.UsingAppsignalDecorators#transaction_with_return_value" =
             FakeTransaction.action(fake_transaction)

    assert [transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "instrument module function with category", %{fake_transaction: fake_transaction} do
    transaction = FakeTransaction.start("bar", :http_request)
    UsingAppsignalDecoratorsWithCustomNamespaces.bar(123)
    assert [^transaction, ^transaction] = FakeTransaction.started_events(fake_transaction)

    assert [
             %{
               body: "",
               body_format: 0,
               name: "bar.http",
               title: "Elixir.UsingAppsignalDecoratorsWithCustomNamespaces.bar",
               transaction: ^transaction
             },
             %{
               body: "",
               body_format: 0,
               name: "nested.db",
               title: "Elixir.UsingAppsignalDecoratorsWithCustomNamespaces.nested",
               transaction: ^transaction
             }
           ] = FakeTransaction.finished_events(fake_transaction)
  end

  describe "when AppSignal is disabled" do
    test "does not start a transaction", %{fake_transaction: fake_transaction} do
      AppsignalTest.Utils.with_config(%{active: false}, fn ->
        UsingAppsignalDecorators.transaction()
      end)

      refute FakeTransaction.started_transaction?(fake_transaction)
    end
  end
end
