defmodule AppsignalTransactionTest do
  use ExUnit.Case

  alias Appsignal.Transaction

  test "transaction lifecycle" do
    transaction = Transaction.start("test1", :http_request)
    assert %Transaction{} = transaction

    assert transaction = Transaction.start_event(transaction)
    assert transaction = Transaction.finish_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1)
    assert transaction = Transaction.set_error(transaction, "Error", "error message", "['backtrace']")
    assert transaction = Transaction.set_sample_data(transaction, "key", "{'user_id': 1}")
    assert transaction = Transaction.set_action(transaction, "GET:/")
    assert transaction = Transaction.set_queue_start(transaction, 1000)
    assert transaction = Transaction.set_meta_data(transaction, "email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish(transaction))
    assert :ok = Transaction.complete(transaction)
  end
end
