defmodule Appsignal.FakeSystem do
  @behaviour Appsignal.SystemBehaviour

  def hostname_with_domain do
    "Alices-MBP.example.com"
  end

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def root? do
    Agent.get(__MODULE__, &Map.get(&1, :root, false))
  end

  def heroku? do
    Agent.get(__MODULE__, &Map.get(&1, :heroku, false))
  end

  def uid do
    Agent.get(__MODULE__, &Map.get(&1, :uid, 999))
  end

  def agent_platform do
    Agent.get(__MODULE__, &Map.get(&1, :agent_platform, "linux"))
  end
end
