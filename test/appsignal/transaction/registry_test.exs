defmodule Appsignal.Transaction.RegistryTest do
  use ExUnit.Case

  import AppsignalTest.Utils

  alias Appsignal.{Transaction, TransactionRegistry}
  alias Appsignal.Transaction.Receiver

  test "lookup/1 returns nil after process has ended" do
    transaction = %Transaction{id: Transaction.generate_id()}

    pid =
      spawn(fn ->
        TransactionRegistry.register(transaction)
        assert transaction == TransactionRegistry.lookup(self())
      end)

    until(fn ->
      assert transaction == TransactionRegistry.lookup(pid)
    end)

    until(fn ->
      assert nil == TransactionRegistry.lookup(pid)
    end)
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

  describe "lookup/1, with an existing transaction without a monitor" do
    setup :register_transaction_without_monitor

    test "finds an existing transaction by pid", %{transaction: transaction} do
      assert TransactionRegistry.lookup(self()) == transaction
    end
  end

  describe "ignore/1" do
    test "is not ignored by default" do
      refute TransactionRegistry.lookup(:c.pid(0, 990, 0)) == :ignored
    end

    test "ignores a pid" do
      pid = :c.pid(0, 991, 0)
      :ok = TransactionRegistry.ignore(pid)
      assert TransactionRegistry.lookup(pid) == :ignored
    end
  end

  describe "ignore/1, when the registry is not running" do
    setup :terminate_registry

    test "can't ignore a pid" do
      pid = :c.pid(0, 992, 0)
      {:error, :no_receiver} = TransactionRegistry.ignore(pid)
      refute TransactionRegistry.lookup(pid) == :ignored
    end
  end

  describe "register/1, when the registry is not running" do
    setup :terminate_registry

    test "returns nil" do
      assert nil == TransactionRegistry.register(%Transaction{})
    end
  end

  describe "register/1, when disabled" do
    test "returns nil" do
      with_config(%{active: false}, fn ->
        assert nil == TransactionRegistry.register(%Transaction{})
      end)
    end
  end

  describe "lookup/1, when the registry is not running" do
    setup [:register_transaction, :terminate_registry]

    test "does not find an existing transaction by pid" do
      assert TransactionRegistry.lookup(self()) == nil
    end
  end

  describe "lookup/1, when disabled" do
    setup :register_transaction

    test "returns nil" do
      with_config(%{active: false}, fn ->
        assert nil == TransactionRegistry.register(%Transaction{})
      end)
    end
  end

  describe "remove_transaction/1, with an existing transaction" do
    setup :register_transaction

    test "removes the transaction from the registry", %{transaction: transaction} do
      assert TransactionRegistry.remove_transaction(transaction) == :ok
      assert TransactionRegistry.lookup(self()) == nil
    end
  end

  describe "remove_transaction/1, with an existing transaction without a monitor" do
    setup :register_transaction_without_monitor

    test "removes the transaction from the registry", %{transaction: transaction} do
      assert TransactionRegistry.remove_transaction(transaction) == :ok
      assert TransactionRegistry.lookup(self()) == nil
    end
  end

  describe "remove_transaction/1, when the registry is not running" do
    setup [:register_transaction, :terminate_registry]

    test "returns no registry error", %{transaction: transaction} do
      assert TransactionRegistry.remove_transaction(transaction) == {:error, :no_receiver}
    end
  end

  defp register_transaction(_) do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)

    [transaction: transaction]
  end

  def register_transaction_without_monitor(_) do
    transaction = %Transaction{id: Transaction.generate_id()}
    true = :ets.insert(:"$appsignal_transaction_registry", {self(), transaction})

    [transaction: transaction]
  end

  defp terminate_registry(_) do
    :ok = Supervisor.terminate_child(Appsignal.Supervisor, Receiver)

    on_exit(fn ->
      {:ok, _} = Supervisor.restart_child(Appsignal.Supervisor, Receiver)
    end)
  end
end
