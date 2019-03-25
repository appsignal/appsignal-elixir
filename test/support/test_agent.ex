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

        # Make sure the spawned process receives DOWN after its parent process
        # is finished (as per https://elixirforum.com/t/3794/5), with a 500 ms
        # timeout.
        ExUnit.Callbacks.on_exit(fn ->
          ref = Process.monitor(pid)
          assert_receive {:DOWN, ^ref, _, _, _}, 500
        end)

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
    end
  end
end
