defmodule Appsignal.Transaction.Receiver do
  # When support for Elixir 1.4 is dropped, please uncomment the below code. The
  # `Task.__using__/1` implements a simple `child_spec` as a temporary process
  # and states to use the `__MODULE__.start_link/1` function.
  #
  # use Task, restart: :permanent

  alias Appsignal.Transaction.ETS
  alias Appsignal.TransactionRegistry, as: Registry

  def start_link do
    with {:ok, pid} <- Task.start_link(&receiver/0) do
      Process.register(pid, __MODULE__)
      {:ok, pid}
    end
  end

  def receiver do
    receive do
      {:DOWN, _ref, :process, pid, _reason} ->
        Process.send_after(self(), {:delete, pid}, 5000)
        receiver()

      {:delete, pid} ->
        ETS.delete(pid)
        receiver()

      _ ->
        receiver()
    end
  end

  def monitor(pid), do: Process.monitor(pid)

  def demonitor(transaction) do
    transaction
    |> Registry.pids_and_monitor_references()
    |> process_demonitor()
  end

  defp process_demonitor([[_, reference] | tail]) do
    Process.demonitor(reference)
    process_demonitor(tail)
  end

  defp process_demonitor([_ | tail]), do: process_demonitor(tail)
  defp process_demonitor([]), do: :ok
end
