defmodule Appsignal.Transaction.RegistryTest do
  use ExUnit.Case, async: false

  alias Appsignal.{Transaction, TransactionRegistry}

  test "lookup/1 returns nil after process has ended" do
    transaction = %Transaction{id: Transaction.generate_id()}

    pid = spawn(fn() ->
      TransactionRegistry.register(transaction)
      assert transaction == TransactionRegistry.lookup(self())
    end)

    :ok = wait_for_process_to_exit(pid)

    assert transaction == TransactionRegistry.lookup(pid)

    :ok = TransactionRegistry.remove_transaction(transaction)

    assert nil == TransactionRegistry.lookup(pid)
  end

  test "delete entry by transaction" do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)
    :ok = TransactionRegistry.remove_transaction(transaction)
    {:error, :not_found} = TransactionRegistry.remove_transaction(transaction)
  end

  describe "register/1 and lookup/1, with an existing transaction" do
    setup :register_transaction

    test "finds an existing transaction by pid", %{transaction: transaction} do
      assert TransactionRegistry.lookup(self()) == transaction
    end
  end

  describe "lookup/1, without an existing transaction" do
    test "does not find an existing transaction by pid" do
      assert TransactionRegistry.lookup(self()) == nil
    end
  end

  describe "register/1, when the registry is not running" do
    setup :terminate_registry

    test "returns nil" do
      assert nil == TransactionRegistry.register(%Transaction{})
    end
  end

  describe "lookup/1, when the registry is not running" do
    setup [:register_transaction, :terminate_registry]

    test "does not find an existing transaction by pid" do
      assert TransactionRegistry.lookup(self()) == nil
    end
  end

  defp register_transaction(_) do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)

    [transaction: transaction]
  end

  defp terminate_registry(_) do
    :ok = Supervisor.terminate_child(Appsignal.Supervisor, TransactionRegistry)

    on_exit(fn ->
      {:ok, _} = Supervisor.restart_child(Appsignal.Supervisor, TransactionRegistry)
    end)
  end

  defp wait_for_process_to_exit(pid) do
    ref = Process.monitor(pid)
    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    after
      500 -> :timeout
    end
  end
end
