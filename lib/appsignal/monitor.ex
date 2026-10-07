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

  def add(pid) do
    GenServer.cast(__MODULE__, {:monitor, pid})
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
    Process.send_after(self(), {:delete, pid, :os.system_time()}, @deletion_delay)
    {:noreply, monitors}
  end

  def handle_info({:delete, pid, down_at}, monitors) do
    close_all(pid, down_at)
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

  # Ending spans calls into the extension. Repeated crashes here would exceed
  # the supervisor's restart limit and take the span registry down with it.
  defp close_all(pid, down_at) do
    Tracer.close_all(pid, end_time: down_at)
  catch
    kind, reason ->
      Appsignal.IntegrationLogger.debug(
        "Appsignal.Monitor could not close the spans of #{inspect(pid)}: " <>
          Exception.format(kind, reason, __STACKTRACE__)
      )
  end

  defp monitored_pids do
    {:monitors, monitors} = Process.info(self(), :monitors)
    Enum.map(monitors, fn {:process, process} -> process end)
  end

  defp schedule_sync do
    Process.send_after(self(), :sync, @sync_interval)
  end
end
