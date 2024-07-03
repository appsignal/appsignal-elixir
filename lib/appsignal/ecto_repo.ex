defmodule Appsignal.Ecto.Repo do
  @ecto_repo Application.compile_env(:appsignal, :ecto_repo, Ecto.Repo)

  defmacro __using__(opts) do
    quote do
      use unquote(@ecto_repo), unquote(opts)

      def default_options(atom) do
        Appsignal.Ecto.Repo.default_options(atom)
      end
    end
  end

  def default_options(_atom) do
    [
      telemetry_options: [
        _appsignal_current_span: Appsignal.Tracer.current_span()
      ]
    ]
  end
end
