defmodule AppsignalTransactionRegistryTest do
  use ExUnit.Case

  alias Appsignal.{Transaction, TransactionRegistry}

  test "transaction registration" do
    transaction = %Transaction{}

    TransactionRegistry.register(transaction)

    assert ^transaction = TransactionRegistry.lookup(self)
  end


  test "lookup returns nil after process has ended" do
    transaction = %Transaction{}

    pid = spawn(fn() ->
      TransactionRegistry.register(transaction)
      assert ^transaction = TransactionRegistry.lookup(self)
      :timer.sleep(50)
    end)

    :timer.sleep(10)

    assert ^transaction = TransactionRegistry.lookup(pid)

    :timer.sleep(100)
    # by now the process is gone
    #assert nil == TransactionRegistry.lookup(pid)

  end

end
