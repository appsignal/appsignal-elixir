defmodule Appsignal.TransactionRegistry do
  @moduledoc """

  Internal module which keeps a registry of the transaction handles
  linked to their originating process.

  This is used on various places to link a calling process to its transaction.
  For instance, the `Appsignal.ErrorHandler` module uses it to be able to
  complete the transaction in case the originating process crashed.

  The transactions are stored in an ETS table (with
  `{:write_concurrency, true}`, so no bottleneck is created); and the
  originating process is monitored to clean up the ETS table when the
  process has finished.
  """

  require Logger

  alias Appsignal.{Config, Transaction}
  alias Appsignal.Transaction.{ETS, Receiver}

  @doc """
  Register the current process as the owner of the given transaction.
  """
  @spec register(Transaction.t()) :: :ok
  def register(transaction) do
    if Config.active?() && receiver_alive?() do
      pid = self()
      true = ETS.insert({pid, transaction, Receiver.monitor(pid)})
      :ok
    end
  end

  @doc """
  Given a process ID, return its associated transaction.
  """
  @spec lookup(pid) :: Transaction.t() | nil
  def lookup(pid) do
    case Config.active?() && receiver_alive?() && ETS.lookup(pid) do
      [{^pid, %Transaction{} = transaction, _}] -> transaction
      [{^pid, %Transaction{} = transaction}] -> transaction
      [{^pid, :ignore}] -> :ignored
      _ -> nil
    end
  end

  @doc false
  @spec lookup(pid, boolean) :: Transaction.t() | nil | :removed
  def lookup(pid, return_removed) do
    IO.warn(
      "Appsignal.TransactionRegistry.lookup/2 is deprecated. Use Appsignal.TransactionRegistry.lookup/1 instead"
    )

    case receiver_alive?() && ETS.lookup(pid) do
      [{^pid, :removed}] ->
        case return_removed do
          false -> nil
          true -> :removed
        end

      [{^pid, transaction, _}] ->
        transaction

      [{^pid, transaction}] ->
        transaction

      false ->
        nil

      [] ->
        nil
    end
  end

  @doc """
  Unregister the current process as the owner of the given transaction.
  """
  @spec remove_transaction(Transaction.t()) :: :ok | {:error, :not_found} | {:error, :no_receiver}
  def remove_transaction(%Transaction{} = transaction) do
    if receiver_alive?() do
      transaction
      |> pids_and_monitor_references()
      |> Receiver.demonitor()

      remove(transaction)
    else
      {:error, :no_receiver}
    end
  end

  defp remove(transaction) do
    case pids_and_monitor_references(transaction) do
      [[_pid, _reference] | _] = pids_and_refs ->
        delete(pids_and_refs)

      [[_pid] | _] = pids ->
        delete(pids)

      [] ->
        {:error, :not_found}
    end
  end

  @doc """
  Ignore a process in the error handler.
  """
  @spec ignore(pid()) :: :ok
  def ignore(pid) do
    if receiver_alive?() do
      ETS.insert({pid, :ignore})
      :ok
    else
      {:error, :no_receiver}
    end
  end

  @doc """
  Check if a progress is ignored.
  """
  @deprecated "Use Appsignal.TransactionRegistry.lookup/1 instead."
  @spec ignored?(pid()) :: boolean()
  def ignored?(pid) do
    case receiver_alive?() && ETS.lookup(pid) do
      [{^pid, :ignore}] -> true
      _ -> false
    end
  end

  defp delete([[pid, _] | tail]) do
    ETS.delete(pid)
    delete(tail)
  end

  defp delete([[pid] | tail]) do
    ETS.delete(pid)
    delete(tail)
  end

  defp delete([]), do: :ok

  defp receiver_alive? do
    pid = Process.whereis(Receiver)
    !is_nil(pid) && Process.alive?(pid)
  end

  def pids_and_monitor_references(transaction) do
    ETS.match({:"$1", transaction, :"$2"})
  end
end
