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

  @table :'$appsignal_transaction_registry'

  alias Appsignal.Transaction

  @spec start_link :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Register the current process as the owner of the given transaction.
  """
  @spec register(Transaction.t) :: :ok
  def register(transaction) do
    pid = self()
    if registry_alive?() do
      true = :ets.insert(@table, {pid, transaction})
      GenServer.cast(__MODULE__, {:monitor, pid})
    else
      Logger.debug("Appsignal was not started, skipping transaction registration.")
      nil
    end
  end

  @doc """
  Given a process ID, return its associated transaction.
  """
  @spec lookup(pid, boolean) :: Transaction.t | nil
  def lookup(pid, return_removed \\ false) do
    case registry_alive?() && :ets.lookup(@table, pid) do
      [{^pid, :removed}] ->
        case return_removed do
          false -> nil
          true -> :removed
        end
      [{^pid, transaction}] -> transaction
      false ->
        Logger.debug("Appsignal was not started, skipping transaction lookup.")
        nil
      [] -> nil
    end
  end

  @doc """
  Unregister the current process as the owner of the given transaction.
  """
  @spec remove_transaction(Transaction.t) :: :ok | {:error, :not_found}
  def remove_transaction(%Transaction{} = transaction) do
    GenServer.call(__MODULE__, {:remove, transaction})
  end

  ##

  defmodule State do
    @moduledoc false
    defstruct table: nil
  end

  def init([]) do
    table = :ets.new(@table, [:set, :named_table,
                              {:keypos, 1}, :public, {:write_concurrency, true}])
    {:ok, %State{table: table}}
  end

  def handle_call({:remove, transaction}, _from, state) do
    reply =
      case :ets.match(@table, {:'$1', transaction}) do
        [[_pid] | _] = pids ->
          for [pid] <- pids do
            true = :ets.delete(@table, pid)
            true = :ets.insert(@table, {pid, :removed})
            Process.send_after(self(), {:delete, pid}, 5000)
          end
          :ok
        [] ->
          {:error, :not_found}
      end
    {:reply, reply, state}
  end

  def handle_cast({:monitor, pid}, state) do
    Process.monitor(pid)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # we give the error handler some time to process the error report
    Process.send_after(self(), {:delete, pid}, 5000)
    {:noreply, state}
  end

  def handle_info({:delete, pid}, state) do
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
