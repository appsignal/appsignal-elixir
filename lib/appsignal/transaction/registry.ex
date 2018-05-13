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

  use GenServer

  require Logger

  @table :"$appsignal_transaction_registry"
  @index :"$appsignal_transaction_index"

  alias Appsignal.Transaction

  @spec start_link :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Register the current process as the owner of the given transaction.
  """
  @spec register(Transaction.t()) :: :ok
  def register(transaction) do
    pid = self()

    if registry_alive?() do
      monitor_reference = GenServer.call(__MODULE__, {:monitor, pid})
      transaction = %{transaction | monitor_reference: monitor_reference}
      true = :ets.insert(@table, {pid, transaction})
      true = :ets.insert(@index, {transaction.id, pid})
      :ok
    else
      Logger.debug("AppSignal was not started, skipping transaction registration.")
      nil
    end
  end

  @doc """
  Given a process ID, return its associated transaction.
  """
  @spec lookup(pid) :: Transaction.t() | nil
  def lookup(pid) do
    case registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, %Transaction{} = transaction, _}] ->
        transaction

      [{^pid, %Transaction{} = transaction}] ->
        transaction

      false ->
        Logger.debug("AppSignal was not started, skipping transaction lookup.")
        nil

      _ ->
        nil
    end
  end

  @spec lookup(pid, boolean) :: Transaction.t | nil | :removed
  @doc false
  def lookup(pid, return_removed) do
    IO.warn "Appsignal.TransactionRegistry.lookup/2 is deprecated. Use Appsignal.TransactionRegistry.lookup/1 instead"

    case registry_alive?() && :ets.lookup(@table, pid) do
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
        Logger.debug("AppSignal was not started, skipping transaction lookup.")
        nil

      [] ->
        nil
    end
  end

  @doc """
  Unregister the current process as the owner of the given transaction.
  """
  @spec remove_transaction(Transaction.t) :: :ok | {:error, :not_found}
  def remove_transaction(%Transaction{id: id}) do
    case :ets.lookup(@index, id) do
      [{^id, pid}] ->
        transaction = lookup(pid)
        GenServer.cast(__MODULE__, {:demonitor, transaction})
        GenServer.call(__MODULE__, {:remove, transaction})
      [] ->
        {:error, :not_found}
    end
  end

  def set_action(%Transaction{id: id}, action) do
    case :ets.lookup(@index, id) do
      [{^id, pid}] ->
        transaction = %{lookup(pid) | action: action}

        true = :ets.insert(@table, {pid, transaction})
        :ok
      [] ->
        {:error, :not_found}
    end
  end

  def action(%Transaction{id: id}) do
    case :ets.lookup(@index, id) do
      [{^id, pid}] -> lookup(pid).action
      [] -> {:error, :not_found}
    end
  end

  defmodule State do
    @moduledoc false
    defstruct table: nil
  end

  def init([]) do
    :ets.new(@index, [:set, :named_table, :public, {:write_concurrency, true}])

    table =
      :ets.new(@table, [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])

    {:ok, %State{table: table}}
  end

  def handle_call({:remove, %Transaction{id: id}}, _from, state) do
    reply =
      case :ets.lookup(@index, id) do
        [{^id, pid}] when is_pid(pid) -> Process.send(self(), {:delete, pid}, [])
        _ -> {:error, :not_found}
      end

    {:reply, reply, state}
  end

  def handle_call({:monitor, pid}, _from, state) do
    monitor_reference = Process.monitor(pid)
    {:reply, monitor_reference, state}
  end

  def handle_cast({:demonitor, %Transaction{monitor_reference: monitor_reference}}, state) do
    Process.demonitor(monitor_reference)

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # we give the error handler some time to process the error report
    Process.send_after(self(), {:delete, pid}, 5000)
    {:noreply, state}
  end

  def handle_info({:delete, pid}, state) do
    case lookup(pid) do
      %Transaction{id: id} -> :ets.delete(@index, id)
      _ -> :ok
    end

    :ets.delete(@table, pid)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp registry_alive? do
    pid = Process.whereis(__MODULE__)
    !is_nil(pid) && Process.alive?(pid)
  end
end
