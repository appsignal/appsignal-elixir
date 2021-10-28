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
      raise "Fake probe failed!"
    end
  end

  def clear do
    if alive?() do
      update(__MODULE__, :probe_called, false)
    end
  end

  def stateful(state) do
    if alive?() do
      update(__MODULE__, :probe_called, true)
      update(__MODULE__, :probe_state, state)
    end

    state + 1
  end
end
