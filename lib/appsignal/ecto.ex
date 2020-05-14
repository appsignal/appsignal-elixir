defmodule Appsignal.Ecto do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)

  def attach do
    otp_app =
      :appsignal
      |> Application.get_env(:config, %{})
      |> Map.get(:otp_app, nil)

    otp_app
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(&attach(otp_app, &1))
  end

  def attach(otp_app, repo) do
    event = telemetry_prefix(otp_app, repo) ++ [:query]
    :telemetry.attach({__MODULE__, event}, event, &query/4, :ok)
  end

  defp telemetry_prefix(otp_app, repo) do
    case otp_app
         |> Application.get_env(repo, [])
         |> Keyword.get(:telemetry_prefix) do
      prefix when is_list(prefix) ->
        prefix

      _ ->
        repo
        |> Module.split()
        |> Enum.map(&(&1 |> Macro.underscore() |> String.to_atom()))
    end
  end

  defp query(_event, _measurements, __metadata, _config) do
    @tracer.create_span("http_request", @tracer.current_span())
  end
end
