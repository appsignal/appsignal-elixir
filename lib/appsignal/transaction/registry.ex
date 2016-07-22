defmodule Appsignal.TransactionRegistry do
  @moduledoc """

  Internal module which keeps a registry of the transaction handles
  linked to their originating process.

  This is used by the Appsignal.ErrorHandler module to be able to
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

  @spec register(Transaction.transaction) :: :ok
  def register(transaction) do
    pid = self()
    true = :ets.insert(@table, {pid, transaction})
    GenServer.cast(__MODULE__, {:monitor, pid})
  end

  @spec register(Transaction.transaction) :: :ok
  def lookup(pid) do
    case :ets.lookup(@table, pid) do
      [{^pid, transaction}] -> transaction
      [] -> nil
    end
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

  def handle_info(msg, state) do
    Logger.warn "info: #{inspect msg}"
    {:noreply, state}
  end


end
