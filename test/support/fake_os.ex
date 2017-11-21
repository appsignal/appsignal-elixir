defmodule FakeOS do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def type do
    Agent.get(__MODULE__, &Map.get(&1, :type, {:unix, :linux}))
  end
end
