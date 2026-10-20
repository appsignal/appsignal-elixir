# HTTPoison, Plug and Phoenix are not dependencies of this package. Without
# them installed, the calls its integrations make into them are unknown, so
# each group applies only when its library is not installed.
unless_installed = fn app, ignores ->
  case Application.load(app) do
    :ok -> []
    {:error, {:already_loaded, ^app}} -> []
    {:error, _} -> ignores
  end
end

List.flatten([
  unless_installed.(:httpoison, [
    {"lib/appsignal/httpoison.ex", :unknown_function}
  ]),
  unless_installed.(:plug, [
    {"lib/appsignal/plug.ex", :unknown_function},
    {"lib/appsignal/plug/metadata.ex", :unknown_function}
  ]),
  unless_installed.(:phoenix, [
    {"lib/appsignal/phoenix/template/eex_engine.ex", :unknown_function},
    {"lib/appsignal/phoenix/template/exs_engine.ex", :unknown_function}
  ])
])
