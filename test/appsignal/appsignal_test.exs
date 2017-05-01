defmodule AppsignalTest do
  use ExUnit.Case
  import Mock
  import AppsignalTest.Utils

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
    Appsignal.set_gauge("key", 10)
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
    Appsignal.add_distribution_value("dist_key", 10)
  end

  test "Agent environment variables" do
    with_env(%{"APPSIGNAL_APP_ENV" => "test"}, fn() ->
      Appsignal.Config.initialize()

      env = Appsignal.Config.get_system_env()
      assert "test" = env["APPSIGNAL_APP_ENV"]

      config = Application.get_env :appsignal, :config
      assert :test = config[:env]
    end)
  end

  alias Appsignal.{Transaction, TransactionRegistry}

  test_with_mock "send_error", Appsignal.Transaction, [:passthrough], [] do
    stack = System.stacktrace()
    Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack)

    t = %Transaction{} = TransactionRegistry.lookup(self())

    assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end

  test_with_mock "send_error with metadata", Appsignal.Transaction, [:passthrough], [] do
    stack = System.stacktrace()
    Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack, %{foo: "bar"})

    t = %Transaction{} = TransactionRegistry.lookup(self())

    assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
    assert called Transaction.set_meta_data(t, :foo, "bar")
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end

  test_with_mock "send_error with a passed function", Appsignal.Transaction, [:passthrough], [] do
    stack = System.stacktrace()
    Appsignal.send_error(
      %RuntimeError{message: "Some bad stuff happened"},
      "Oops",
      stack,
      %{},
      nil,
      fn(t) -> Transaction.set_sample_data(t, "key", %{foo: "bar"}) end
    )

    t = %Transaction{} = TransactionRegistry.lookup(self())

    assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
    assert called Transaction.set_sample_data(t, "key", %{foo: "bar"})
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end
end
