defmodule Appsignal.Monitor do
  @moduledoc false

  @deletion_delay Application.compile_env(:appsignal, :deletion_delay, 5_000)
  @sync_interval Application.compile_env(:appsignal, :sync_interval, 60_000)

  use GenServer
  alias Appsignal.Tracer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    schedule_sync()

    {:ok, MapSet.new()}
  end

  def add do
    GenServer.cast(__MODULE__, {:monitor, self()})
  end

  def handle_cast({:monitor, pid}, monitors) do
    if MapSet.member?(monitors, pid) do
      {:noreply, monitors}
    else
      Process.monitor(pid)
      {:noreply, MapSet.put(monitors, pid)}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, monitors) do
    Process.send_after(self(), {:delete, pid}, @deletion_delay)
    {:noreply, monitors}
  end

  def handle_info({:delete, pid}, monitors) do
    Tracer.delete(pid)
    {:noreply, MapSet.delete(monitors, pid)}
  end

  def handle_info(:sync, _monitors) do
    schedule_sync()

    pids = MapSet.new(monitored_pids())

    Appsignal.IntegrationLogger.debug(
      "Synchronizing monitored PIDs in Appsignal.Monitor (#{MapSet.size(pids)})"
    )

    {:noreply, pids}
  end

  def child_spec(_) do
    %{
      id: Appsignal.Monitor,
      start: {Appsignal.Monitor, :start_link, []}
    }
  end

  defp monitored_pids do
    {:monitors, monitors} = Process.info(self(), :monitors)
    Enum.map(monitors, fn {:process, process} -> process end)
  end

  defp schedule_sync do
    Process.send_after(self(), :sync, @sync_interval)
  end
end
