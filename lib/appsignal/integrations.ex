defmodule Appsignal.Integrations do
  @moduledoc false

  require Logger

  @legacy_packages [:appsignal_plug, :appsignal_phoenix]

  @modules [
    Appsignal.Plug,
    Appsignal.Phoenix,
    Appsignal.Phoenix.Application,
    Appsignal.Phoenix.Channel,
    Appsignal.Phoenix.EventHandler,
    Appsignal.Phoenix.LiveView,
    Appsignal.Phoenix.Template,
    Appsignal.Phoenix.Template.EExEngine,
    Appsignal.Phoenix.Template.ExsEngine,
    Appsignal.Phoenix.View
  ]

  def conflicts do
    packages = Enum.flat_map(@legacy_packages, &legacy_package/1)
    modules = Enum.filter(@modules, &foreign?(:code.which(&1), ebin()))

    case {packages, modules} do
      {[], []} -> :ok
      _ -> {:error, %{packages: packages, modules: modules}}
    end
  end

  def foreign?(path, ebin) when is_list(path) and path != [] do
    not String.starts_with?(List.to_string(path), ebin <> "/")
  end

  def foreign?(_path, _ebin), do: false

  def missing do
    [
      {:plug, Plug.Conn, Appsignal.Plug},
      {:phoenix, Phoenix, Appsignal.Phoenix.EventHandler}
    ]
    |> Enum.filter(fn {_name, library, integration} ->
      Code.ensure_loaded?(library) and not Code.ensure_loaded?(integration)
    end)
    |> Enum.map(fn {name, _library, _integration} -> name end)
  end

  def log_conflicts(%{packages: packages, modules: modules}) do
    Logger.error("""
    AppSignal is disabled, because #{describe(packages, modules)}.

    Since AppSignal for Elixir 3.0, the Plug and Phoenix integrations are part \
    of the appsignal package. The appsignal_plug and appsignal_phoenix packages \
    before 3.0.0 define the same modules, and loading both breaks the \
    instrumentation.

    Remove appsignal_plug and appsignal_phoenix from the dependencies in your \
    mix.exs file, along with any `override: true` on appsignal, and run:

        mix deps.unlock appsignal_plug appsignal_phoenix
        mix deps.get

    See https://docs.appsignal.com/elixir/installation/upgrade-from-2-to-3
    """)
  end

  def log_missing([]), do: :ok

  def log_missing(missing) do
    names = Enum.map_join(missing, " and ", &library_name/1)

    Logger.warning("""
    #{names} is loaded, but AppSignal was compiled without its #{names} \
    integration, so it is not instrumented. Recompile AppSignal with:

        mix deps.compile appsignal --force
    """)
  end

  defp legacy_package(app) do
    _ = Application.load(app)

    case Application.spec(app, :vsn) do
      nil ->
        []

      vsn ->
        version = to_string(vsn)

        case Version.parse(version) do
          {:ok, parsed} ->
            if Version.compare(parsed, "3.0.0") == :lt, do: [{app, version}], else: []

          :error ->
            [{app, version}]
        end
    end
  end

  defp describe([], modules) do
    "#{Enum.map_join(modules, ", ", &inspect/1)} is loaded from outside the appsignal package"
  end

  defp describe(packages, _modules) do
    installed = Enum.map_join(packages, " and ", fn {app, vsn} -> "#{app} #{vsn}" end)
    verb = if length(packages) == 1, do: "is", else: "are"
    "#{installed} #{verb} installed alongside appsignal #{Application.spec(:appsignal, :vsn)}"
  end

  defp library_name(:plug), do: "Plug"
  defp library_name(:phoenix), do: "Phoenix"

  defp ebin do
    :appsignal
    |> :code.lib_dir()
    |> to_string()
    |> Path.join("ebin")
  end
end
