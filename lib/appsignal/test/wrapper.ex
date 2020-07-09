defmodule Appsignal.Test.Wrapper do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Appsignal.Test.Wrapper
      import ExUnit.Assertions

      def start_link do
        Agent.start_link(fn -> %{} end, name: __MODULE__)
      end

      def get!(key) do
        Agent.get(__MODULE__, &Map.fetch!(&1, key))
      end

      def get(key) do
        Agent.get(__MODULE__, &Map.fetch(&1, key))
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

      def child_spec(_opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []},
          type: :worker,
          restart: :permanent,
          shutdown: 500
        }
      end
    end
  end
end
