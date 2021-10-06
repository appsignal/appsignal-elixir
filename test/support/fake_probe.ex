defmodule FakeServerProbe do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
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

defmodule FakeProbe do
  use TestAgent

  def call do
    if alive?() do
      update(__MODULE__, :probe_called, true)
    end
  end

  def fail do
    if alive?() do
      update(__MODULE__, :probe_called, true)
      raise :nosup
    end
  end
end
