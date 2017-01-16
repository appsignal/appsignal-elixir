defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  import Mock


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
