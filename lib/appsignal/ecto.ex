defmodule Appsignal.Ecto do
  def attach do
    :appsignal
    |> Application.get_env(:config, %{})
    |> Map.get(:otp_app)
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(&attach/1)
  end

  def attach(repo) do
    event = telemetry_prefix(repo) ++ [:query]
    :telemetry.attach({__MODULE__, event}, event, &query/4, :ok)
  end

  defp telemetry_prefix(repo) do
    repo
    |> Module.split()
    |> Enum.map(&(&1 |> Macro.underscore() |> String.to_atom()))
  end

  defp query(_event, _measurements, __metadata, _config) do
    :ok
  end
end
