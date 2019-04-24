defmodule Appsignal.TransactionDictionaryTest do
  alias Appsignal.TransactionDictionary
  use ExUnit.Case, async: true
  doctest Appsignal.TransactionDictionary

  setup do
    [transaction: %Appsignal.Transaction{}]
  end

  describe "lookup/0" do
    test "returns nil if there's no Transaction in the dictionary" do
      assert TransactionDictionary.lookup() == nil
    end

    test "returns the current Transaction from the dictionary", %{transaction: transaction} do
      Process.put(:appsignal_transaction, transaction)
      assert TransactionDictionary.lookup() == transaction
    end
  end

  describe "register/1" do
    test "registers a Transaction in the dictionary", %{transaction: transaction} do
      TransactionDictionary.register(transaction)
      assert Process.get(:appsignal_transaction) == transaction
    end
  end

  describe "ignore/0" do
    test "ignores a process" do
      TransactionDictionary.ignore()
      assert Process.get(:appsignal_transaction) == :ignored
    end
  end
end
