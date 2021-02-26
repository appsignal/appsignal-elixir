defmodule TestAgent do
  defmacro __using__(default_state) do
    quote do
      import ExUnit.Assertions

      def start_link do
        {:ok, pid} =
          Agent.start_link(
            fn ->
              unquote(default_state) |> Enum.into(%{})
            end,
            name: __MODULE__
          )

        {:ok, pid}
      end

      def get(pid_or_module, key) do
        Agent.get(pid_or_module, &Map.get(&1, key))
      end

      def update(pid_or_module, key, value) do
        Agent.update(pid_or_module, &Map.put(&1, key, value))
      end

      def alive?() do
        !!Process.whereis(__MODULE__)
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
