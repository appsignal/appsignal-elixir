defmodule Appsignal.Probes.FunctionProbe do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init([function]) do
    {:ok, function}
  end

  def handle_cast(:probe, function) do
    function.()
    {:noreply, function}
  end
end
