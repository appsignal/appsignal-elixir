defmodule FakeFunctionProbe do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> false end)
  end

  def call(pid) do
    fn ->
      if Process.alive?(pid) do
        Agent.update(pid, fn _ -> true end)
      end
    end
  end

  def fail(pid) do
    fn ->
      if Process.alive?(pid) do
        Agent.update(pid, fn _ -> true end)
        raise("Failure")
      end
    end
  end

  def called?(pid) do
    Agent.get(pid, fn state -> state end)
  end

  def clear(pid) do
    Agent.update(pid, fn _ -> false end)
  end
end
