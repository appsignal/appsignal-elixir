defmodule Appsignal.FakeDemo do
  @behaviour Appsignal.DemoBehaviour

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def create_transaction_error_request do
    Agent.update(__MODULE__, &Map.put(&1, :create_transaction_error_request, true))
  end

  def create_transaction_performance_request do
    Agent.update(__MODULE__, &Map.put(&1, :create_transaction_performance_request, true))
  end
end
