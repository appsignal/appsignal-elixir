defmodule Appsignal.FakeNif do
  @behaviour Appsignal.NifBehaviour

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def loaded? do
    Agent.get(__MODULE__, &Map.get(&1, :loaded?, true))
  end

  def running_in_container? do
    Agent.get(__MODULE__, &Map.get(&1, :running_in_container?, true))
  end

  def diagnose do
    if Agent.get(__MODULE__, &Map.get(&1, :run_diagnose, false)) do
      Appsignal.Nif.diagnose
    else
      Agent.get(__MODULE__, &Map.get(&1, :diagnose, "{}"))
    end
  end
end
