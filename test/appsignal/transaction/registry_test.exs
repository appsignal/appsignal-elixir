defmodule Appsignal.Transaction.RegistryTest do
  use ExUnit.Case, async: false

  alias Appsignal.{Transaction, TransactionRegistry}

  test "transaction registration" do
    transaction = %Transaction{}

    TransactionRegistry.register(transaction)

    assert transaction == TransactionRegistry.lookup(self())
  end


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

    # Lookup removed status
    assert :removed == TransactionRegistry.lookup(pid, true)
  end

  test "delete entry by transaction" do
    transaction = %Transaction{id: Transaction.generate_id()}
    TransactionRegistry.register(transaction)
    :ok = TransactionRegistry.remove_transaction(transaction)
    {:error, :not_found} = TransactionRegistry.remove_transaction(transaction)
  end

  describe "when registry is not running" do
    setup do
      :ok = Supervisor.terminate_child(Appsignal.Supervisor, TransactionRegistry)
      on_exit fn ->
        {:ok, _} = Supervisor.restart_child(Appsignal.Supervisor, TransactionRegistry)
      end
    end

    test "register/1 returns nil" do
      transaction = %Transaction{id: Transaction.generate_id()}
      assert nil == TransactionRegistry.register(transaction)
    end

    test "lookup/1 returns nil" do
      assert nil == TransactionRegistry.lookup(self())
    end
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
