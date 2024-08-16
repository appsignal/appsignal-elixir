defmodule FakeEctoRepo do
  defmacro __using__(opts) do
    quote do
      def get_received_opts do
        unquote(opts)
      end

      # As implemented in `Ecto.Repo`:
      # https://github.com/elixir-ecto/ecto/blob/9df9b35044d74322cdd5c263b6d593ba98a19c44/lib/ecto/repo.ex#L260-L261
      def default_options(_operation), do: []
      defoverridable default_options: 1
    end
  end
end
