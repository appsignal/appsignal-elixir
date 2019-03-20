defmodule FakeProbe do
  use TestAgent

  def call, do: update(__MODULE__, :probe_called, true)
end
