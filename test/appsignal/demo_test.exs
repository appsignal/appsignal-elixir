defmodule AppsignalDemoTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "sends a demonstration error", %{fake_transaction: fake_transaction} do
    transaction = Appsignal.Demo.create_transaction_error_request()

    assert "DemoController#hello" = FakeTransaction.action(fake_transaction)

    assert [
             {^transaction, "TestError",
              "Hello world! This is an error used for demonstration purposes.", _stacktrace}
           ] = FakeTransaction.errors(fake_transaction)

    assert %{"demo_sample" => "true"} = FakeTransaction.metadata(fake_transaction)

    assert [transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "sends a performance issue", %{fake_transaction: fake_transaction} do
    transaction = Appsignal.Demo.create_transaction_performance_request()

    assert "DemoController#hello" = FakeTransaction.action(fake_transaction)
    assert %{"demo_sample" => "true"} = FakeTransaction.metadata(fake_transaction)

    assert [^transaction, ^transaction, ^transaction, ^transaction] =
             FakeTransaction.started_events(fake_transaction)

    assert [
             %{
               body: "",
               body_format: 0,
               name: "render.phoenix_template",
               title: "Rendering something slow",
               transaction: ^transaction
             },
             %{
               body: "",
               body_format: 0,
               name: "render.phoenix_template",
               title: "Rendering something slow",
               transaction: ^transaction
             },
             %{
               body: "",
               body_format: 0,
               name: "query.ecto",
               title: "Slow query",
               transaction: ^transaction
             },
             %{
               body: "",
               body_format: 0,
               name: "query.ecto",
               title: "Slow query",
               transaction: ^transaction
             }
           ] = FakeTransaction.finished_events(fake_transaction)

    assert [transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end
end
