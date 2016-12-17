defmodule AppsignalTest do
  use ExUnit.Case
  import Mock

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

  test "started?" do
    assert Appsignal.started?
  end

  test "Agent environment variables" do
    System.put_env("APPSIGNAL_ENVIRONMENT", "test")
    Application.put_env(:appsignal, :config, env: :test)

    Appsignal.Config.initialize()

    env = Appsignal.Config.get_system_env()
    assert "test" = env["APPSIGNAL_ENVIRONMENT"]

    config = Application.get_env :appsignal, :config
    assert :test = config[:env]
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

  test_with_mock "send_error with metadata and conn", Appsignal.Transaction, [:passthrough], [] do
    conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}}
    stack = System.stacktrace()
    Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack, %{foo: "bar"}, conn)

    t = %Transaction{} = TransactionRegistry.lookup(self())

    assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
    assert called Transaction.set_meta_data(t, :foo, "bar")
    assert called Transaction.set_request_metadata(t, conn)
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end
end
