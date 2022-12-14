defmodule Appsignal.FakeAppsignal do
  use TestAgent, %{
    gauges: [],
    counters: [],
    distribution_values: []
  }

  def add_distribution_value(key, value, tags \\ %{}) do
    add(:distribution_values, %{key: key, value: value, tags: tags})
  end

  def increment_counter(key, value \\ 1, tags \\ %{}) do
    add(:counters, %{key: key, value: value, tags: tags})
  end

  def set_gauge(key, value, tags \\ %{}) do
    add(:gauges, %{key: key, value: value, tags: tags})
  end

  def get_distribution_values(key) do
    Enum.filter(get(__MODULE__, :distribution_values), fn element ->
      match?(%{key: ^key, tags: _, value: _}, element)
    end)
  end

  def get_counters(key) do
    Enum.filter(get(__MODULE__, :counters), fn element ->
      match?(%{key: ^key, tags: _, value: _}, element)
    end)
  end

  def get_gauges(key) do
    Enum.filter(get(__MODULE__, :gauges), fn element ->
      match?(%{key: ^key, tags: _, value: _}, element)
    end)
  end

  defp add(key, event) do
    if alive?() do
      Agent.update(__MODULE__, fn state ->
        Map.update!(state, key, fn current -> [event | current] end)
      end)
    end
  end
end
