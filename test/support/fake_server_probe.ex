defmodule FakeServerProbe do
  use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_state) do
    {:ok, false}
  end

  def probed?(pid) do
    GenServer.call(pid, :probed?)
  end

  def handle_cast(:probe, _state) do
    {:noreply, true}
  end

  def handle_call(:probed?, _from, state) do
    {:reply, state, state}
  end
end
