defmodule Appsignal.TransactionDictionary do
  @moduledoc """
  Functions for writing to and reading from the in-process Transaction
  dictionary.

  ## Examples
      iex> Appsignal.TransactionDictionary.lookup()
      nil

      iex> Appsignal.TransactionDictionary.register(%Appsignal.Transaction{})
      :ok
      iex> Appsignal.TransactionDictionary.lookup()
      %Appsignal.Transaction{}

      iex> Appsignal.TransactionDictionary.ignore()
      :ok
      iex> Appsignal.TransactionDictionary.lookup()
      :ignored
  """

  @spec lookup() :: %Appsignal.Transaction{} | :ignored | nil
  def(lookup) do
    Process.get(:appsignal_transaction)
  end

  @spec register(%Appsignal.Transaction{}) :: :ok
  def register(transaction) do
    Process.put(:appsignal_transaction, transaction)
    :ok
  end

  def ignore do
    Process.put(:appsignal_transaction, :ignored)
    :ok
  end
end
