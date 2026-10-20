defmodule Appsignal.Ecto.Repo do
  @ecto_repo Application.compile_env(:appsignal, :ecto_repo, Ecto.Repo)

  defmacro __using__(opts) do
    case Appsignal.Dependencies.match?(:ecto, ">= 3.4.0") do
      true -> instrumentation(opts)
      false -> quote(do: use(unquote(@ecto_repo), unquote(opts)))
    end
  end

  defp instrumentation(opts) do
    quote do
      use unquote(@ecto_repo), unquote(opts)

      def default_options(operation) do
        super(operation) ++ Appsignal.Ecto.Repo.default_options()
      end

      defoverridable default_options: 1
    end
  end

  def default_options(_operation \\ nil) do
    [
      telemetry_options: [
        _appsignal_current_span: Appsignal.Tracer.current_span()
      ]
    ]
  end
end
