defmodule Appsignal.WrappedNif do
  alias Appsignal.Nif

  def start_link do
    {:ok, pid} = Agent.start_link(fn -> %{create_root_span: []} end, name: __MODULE__)
  end

  def create_root_span(name) do
    add(:create_root_span, name)
    Nif.create_root_span(name)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.fetch!(&1, key))
  end

  defp add(key, value) do
    Agent.get_and_update(__MODULE__, fn state ->
      Map.get_and_update(state, key, fn current ->
        case current do
          nil -> {nil, [value]}
          _ -> {current, [value | current]}
        end
      end)
    end)
  end
end
