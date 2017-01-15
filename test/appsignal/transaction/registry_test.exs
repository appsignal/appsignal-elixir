defmodule Appsignal.Transaction.RegistryTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.{Transaction, TransactionRegistry}

  test "transaction registration" do
    transaction = %Transaction{}

    TransactionRegistry.register(transaction)

    assert ^transaction = TransactionRegistry.lookup(self())
  end


  test "lookup returns nil after process has ended" do
    transaction = %Transaction{id: Transaction.generate_id()}

    pid = spawn(fn() ->
      TransactionRegistry.register(transaction)
      assert ^transaction = TransactionRegistry.lookup(self())
      :timer.sleep(50)
    end)

    :timer.sleep(10)

    assert ^transaction = TransactionRegistry.lookup(pid)

    :timer.sleep(100)
    # by now the process is gone

    :ok = TransactionRegistry.remove_transaction(transaction)

    assert nil == TransactionRegistry.lookup(pid)

    # Lookup removed status
    assert :removed == TransactionRegistry.lookup(pid, true)

  end

  test_with_mock "lookup returns nil if appsignal is not started", Appsignal, [], [
    started?: fn() -> false end
  ] do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)
    assert nil == TransactionRegistry.lookup(self())
  end

  test "delete entry by transaction" do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)
    :ok = TransactionRegistry.remove_transaction(transaction)
    {:error, :not_found} = TransactionRegistry.remove_transaction(transaction)
  end

end
