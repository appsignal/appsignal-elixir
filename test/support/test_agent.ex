defmodule TestAgent do
  defmacro __using__(default_state) do
    quote do
      def start_link(state \\ %{}) do
        Agent.start_link(fn() ->
            unquote(default_state)
            |> Enum.into(%{})
            |> Map.merge(state)
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

