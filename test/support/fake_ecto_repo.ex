defmodule FakeEctoRepo do
  defmacro __using__(opts) do
    quote do
      def get_received_opts do
        unquote(opts)
      end
    end
  end
end
