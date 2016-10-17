defmodule AppsignalTransactionTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.Transaction

  test "transaction lifecycle" do
    transaction = Transaction.start("test1", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event(transaction)
    assert ^transaction = Transaction.finish_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1)
    assert ^transaction = Transaction.record_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert ^transaction = Transaction.set_error(transaction, "Error", "error message", "['backtrace']")
    assert ^transaction = Transaction.set_sample_data(transaction, "key", "{'user_id': 1}")
    assert ^transaction = Transaction.set_action(transaction, "GET:/")
    assert ^transaction = Transaction.set_queue_start(transaction, 1000)
    assert ^transaction = Transaction.set_meta_data(transaction, "email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish(transaction))
    assert :ok = Transaction.complete(transaction)
  end

  test "use default transaction in Transaction calls" do

    transaction = Transaction.start("test2", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event()
    assert ^transaction = Transaction.finish_event("sql.query", "Model load", "SELECT * FROM table;", 1)
    assert ^transaction = Transaction.record_event("sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert ^transaction = Transaction.set_error("Error", "error message", "['backtrace']")
    assert ^transaction = Transaction.set_sample_data("key", "{'user_id': 1}")
    assert ^transaction = Transaction.set_action("GET:/")
    assert ^transaction = Transaction.set_queue_start(1000)
    assert ^transaction = Transaction.set_meta_data("email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish())
    assert :ok = Transaction.complete()

  end

  test_with_mock "use shorthand set_meta_data function", Appsignal.Transaction, [:passthrough], [] do

    transaction = Transaction.start("test3", :http_request)
    assert %Transaction{} = transaction

    Transaction.set_meta_data(email: "email@email.com")

    assert called Transaction.set_meta_data(transaction, "email", "email@email.com")

    Transaction.set_meta_data(%{"foo" => "bar", "value" => 123})
    assert called Transaction.set_meta_data(transaction, "foo", "bar")
    assert called Transaction.set_meta_data(transaction, "value", "123")

    assert :ok = Transaction.complete()

  end

end
