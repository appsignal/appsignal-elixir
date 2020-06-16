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

  def handle_cast({:monitor, pid}, state) do
    Process.monitor(pid)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    Process.send_after(self(), {:delete, pid}, @deletion_delay)
    {:noreply, state}
  end

  def handle_info({:delete, pid}, state) do
    Tracer.delete(pid)
    {:noreply, state}
  end
end
