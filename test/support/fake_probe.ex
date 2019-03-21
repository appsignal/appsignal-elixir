defmodule FakeProbe do
  use TestAgent

  def call do
    if alive? do
      update(__MODULE__, :probe_called, true)
    end
  end
end
