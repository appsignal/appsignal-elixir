defmodule AppsignalDemoTest do
  use ExUnit.Case
  import Mock
  alias Appsignal.{Transaction, TransactionRegistry}

  test "starts and stops the AppSignal agent" do
    with_mocks([
      {Appsignal,
       [],
       [start: fn(_, _) -> nil end,
        stop: fn(_) -> nil end,
        started?: fn() -> true end]},
      {Appsignal.Demo,
       [:passthrough],
       []}
    ]) do
      Appsignal.Demo.transmit

      assert called Appsignal.start(nil, nil)
      assert called Appsignal.Demo.create_transaction_performance_request
      assert called Appsignal.Demo.create_transaction_error_request
      assert called Appsignal.stop(nil)
    end
  end

  test_with_mock "sends a demonstration error", Appsignal.Transaction, [:passthrough], [] do
    Appsignal.Demo.create_transaction_error_request

    t = %Transaction{} = TransactionRegistry.lookup(self())
    assert called Appsignal.Transaction.set_action(t, "DemoController#hello")
    assert called Appsignal.Transaction.set_error(t, "TestError", "Hello world! This is an error used for demonstration purposes.", [])
    assert called Appsignal.Transaction.set_meta_data(t, "demo_sample", "true")
    assert called Appsignal.Transaction.finish(t)
    assert called Appsignal.Transaction.complete(t)
  end

  test_with_mock "sends a performance issue", Appsignal.Transaction, [:passthrough], [] do
    Appsignal.Demo.create_transaction_performance_request

    t = %Transaction{} = TransactionRegistry.lookup(self())
    assert called Appsignal.Transaction.set_action(t, "DemoController#hello")
    assert called Appsignal.Transaction.set_meta_data(t, "demo_sample", "true")
    assert called Appsignal.Transaction.start_event(t)
    assert called Appsignal.Transaction.finish_event(t, "template.render", "Rendering something slow", "", 0)
    assert called Appsignal.Transaction.finish(t)
    assert called Appsignal.Transaction.complete(t)
  end
end
