defmodule FakeFunctionProbe do
  use TestAgent

  def call(pid) do
    fn ->
      if alive?() do
        update(pid, :probe_called, true)
      end
    end
  end

  def fail(pid) do
    fn ->
      if alive?() do
        update(pid, :probe_called, true)
        raise("Failure")
      end
    end
  end
end
