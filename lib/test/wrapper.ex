defmodule Appsignal.Test.Wrapper do
  defmacro __using__(_) do
    quote do
      import Appsignal.Test.Wrapper
      import ExUnit.Assertions

      def start_link do
        {:ok, pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)

        ExUnit.Callbacks.on_exit(fn ->
          ref = Process.monitor(pid)
          assert_receive {:DOWN, ^ref, _, _, _}, 500
        end)

        {:ok, pid}
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
  end
end
