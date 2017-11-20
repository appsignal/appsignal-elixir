defmodule TestAgent do
  defmacro __using__(initial_state) do
    quote do
      def start_link do
        Agent.start_link(fn() ->
            unquote(initial_state) |> Enum.into(%{})
          end,
          name: __MODULE__
        )
      end

      def get(pid_or_module, key) do
        Agent.get(pid_or_module, &Map.get(&1, key))
      end

      def update(pid_or_module, key, value) do
        Agent.update(pid_or_module, &Map.put(&1, key, value))
      end
    end
  end
end

