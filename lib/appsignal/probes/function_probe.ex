defmodule Appsignal.Probes.FunctionProbe do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init([function]) do
    {:ok, function}
  end

  def handle_cast(:probe, function) do
    function.()
    {:noreply, function}
  end
end
