defmodule Appsignal.Ecto do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)
  import Appsignal.Utils, only: [module_name: 1]

  require Logger

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

    case :telemetry.attach({__MODULE__, event}, event, &handle_event/4, :ok) do
      :ok ->
        Logger.debug("Appsignal.Ecto attached to #{inspect(event)}")

      {:error, _} = error ->
        Logger.warn("Appsignal.Ecto not attached to #{inspect(event)}: #{inspect(error)}")
    end
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

  def handle_event(_event, _measurements, %{query: "begin"}, _config), do: :ok
  def handle_event(_event, _measurements, %{query: "commit"}, _config), do: :ok

  def handle_event(_event, %{total_time: total_time}, %{repo: repo, query: query}, _config) do
    time = :os.system_time()

    "http_request"
    |> @tracer.create_span(@tracer.current_span(), start_time: time - total_time)
    |> @span.set_name("Query #{module_name(repo)}")
    |> @span.set_attribute("appsignal:category", "query.ecto")
    |> @span.set_sql(query)
    |> @tracer.close_span(end_time: time)
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok
end
