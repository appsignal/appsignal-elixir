defmodule Appsignal.Monitor do
  @moduledoc false
  @deletion_delay Application.get_env(:appsignal, :deletion_delay, 5_000)

  use GenServer
  alias Appsignal.Tracer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def add do
    GenServer.cast(__MODULE__, {:monitor, self()})
  end

  def handle_cast({:monitor, pid}, monitors) do
    if pid in monitors do
      {:noreply, monitors}
    else
      Process.monitor(pid)
      {:noreply, [pid | monitors]}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, monitors) do
    Process.send_after(self(), {:delete, pid}, @deletion_delay)
    {:noreply, monitors}
  end

  def handle_info({:delete, pid}, monitors) do
    Tracer.delete(pid)
    {:noreply, List.delete(monitors, pid)}
  end

  def child_spec(_) do
    %{
      id: Appsignal.Monitor,
      start: {Appsignal.Monitor, :start_link, []}
    }
  end
end
