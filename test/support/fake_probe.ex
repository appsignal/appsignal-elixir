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
