defmodule Appsignal.FakeAppsignal do
  use TestAgent, %{
    gauges: []
  }

  def set_gauge(key, value, tags \\ %{}) do
    if alive?() do
      Agent.update(__MODULE__, fn state ->
        {_, new_state} =
          Map.get_and_update(state, :gauges, fn current ->
            gauge = %{key: key, value: value, tags: tags}

            case current do
              nil -> {nil, [gauge]}
              _ -> {current, [gauge | current]}
            end
          end)

        new_state
      end)
    end
  end

  def get_gauges(key) do
    Enum.filter(get(__MODULE__, :gauges), fn element ->
      match?(%{key: ^key, tags: _, value: _}, element)
    end)
  end
end
