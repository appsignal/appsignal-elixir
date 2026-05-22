defmodule Appsignal.Ecto do
  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @appsignal Application.compile_env(:appsignal, :appsignal, Appsignal)
  import Appsignal.Utils, only: [module_name: 1, native_to_milliseconds: 1]

  # For each measurement Ecto emits, the tag combinations we want to fan out to.
  # `:hostname` -> tagged by repo + hostname (BEAM-side dimension).
  # `:source` -> tagged by repo + source (table-side dimension), only relevant
  # for measurements that vary with the query shape.
  @measurement_tag_modes [
    query_time: [:hostname, :source],
    queue_time: [:hostname],
    decode_time: [:hostname, :source],
    idle_time: [:hostname],
    total_time: [:hostname, :source]
  ]

  @doc """
  Attaches `Appsignal.Ecto` to the Ecto telemetry channel configured in the
  application's configuration.
  """
  def attach do
    otp_app =
      :appsignal
      |> Application.get_env(:config, %{})
      |> Map.get(:otp_app, nil)

    otp_app
    |> repos()
    |> Enum.each(&attach(otp_app, &1))
  end

  @doc """
  Attaches `Appsignal.Ecto` to the Ecto telemetry channel based on the passed
  `otp_app` and `repo`.
  """
  def attach(otp_app, repo) do
    event = telemetry_prefix(otp_app, repo) ++ [:query]

    case :telemetry.attach({__MODULE__, event}, event, &__MODULE__.handle_event/4, :ok) do
      :ok ->
        Appsignal.IntegrationLogger.debug("Appsignal.Ecto attached to #{inspect(event)}")

        :ok

      {:error, _} = error ->
        Logger.warning("Appsignal.Ecto not attached to #{inspect(event)}: #{inspect(error)}")

        error
    end
  end

  defp repos(otp_app) do
    Application.get_env(:appsignal, :config, %{})[:ecto_repos] ||
      Application.get_env(otp_app, :ecto_repos) ||
      []
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

  @doc false
  def handle_event(
        _event,
        %{total_time: total_time} = measurements,
        %{repo: repo, query: query} = metadata,
        _config
      ) do
    add_measurement_distributions(repo, measurements, metadata)
    do_handle_event(current_span(metadata), total_time, repo, query)
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok

  defp add_measurement_distributions(repo, measurements, metadata) do
    repo_name = module_name(repo)
    hostname_tags = %{repo: repo_name, hostname: Appsignal.Utils.Hostname.hostname()}
    source_tags = source_tags(repo_name, metadata)

    Enum.each(@measurement_tag_modes, fn {key, modes} ->
      value = Map.get(measurements, key)

      if is_integer(value) do
        ms = native_to_milliseconds(value)
        metric = "ecto_#{key}"

        if :hostname in modes do
          @appsignal.add_distribution_value(metric, ms, hostname_tags)
        end

        if :source in modes and source_tags do
          @appsignal.add_distribution_value(metric, ms, source_tags)
        end
      end
    end)
  end

  defp source_tags(repo_name, %{source: source}) when is_binary(source) do
    %{repo: repo_name, source: source}
  end

  defp source_tags(_repo_name, _metadata), do: nil

  defp current_span(metadata) do
    # If a current span is already set in this process, use that instead
    # of the current span passed as part of the Ecto metadata.
    # This fixes an issue where, when a transaction takes place in a
    # parallel preload process, `handle_commit/3` and `handle_rollback/3`
    # would not close the span created by `handle_begin/3`, but the span's
    # parent.
    @tracer.current_span() || metadata[:options][:_appsignal_current_span]
  end

  defp do_handle_event(nil, _total_time, _repo, _query), do: nil

  defp do_handle_event(current_span, total_time, repo, query) do
    case query do
      "begin" -> handle_begin(current_span, total_time, repo)
      "commit" -> handle_commit(current_span, total_time, repo)
      "rollback" -> handle_rollback(current_span, total_time, repo)
      _ -> handle_query(current_span, total_time, repo, query)
    end
  end

  defp handle_begin(current_span, total_time, repo) do
    time = :os.system_time()

    # Intentionally leave span open to be closed
    # by `handle_commit/3` or `handle_rollback/3`
    "http_request"
    |> @tracer.create_span(current_span, start_time: time - total_time)
    |> @span.set_name("Transaction #{module_name(repo)}")
    |> @span.set_attribute("appsignal:category", "transaction.ecto")
  end

  defp handle_commit(current_span, total_time, repo) do
    time = :os.system_time()

    "http_request"
    |> @tracer.create_span(current_span, start_time: time - total_time)
    |> @span.set_name("Commit #{module_name(repo)}")
    |> @span.set_attribute("appsignal:category", "commit.ecto")
    |> @tracer.close_span(end_time: time)

    # Close span created by `handle_begin/3`
    @tracer.close_span(current_span, end_time: time)
  end

  defp handle_rollback(current_span, total_time, repo) do
    time = :os.system_time()

    "http_request"
    |> @tracer.create_span(current_span, start_time: time - total_time)
    |> @span.set_name("Rollback #{module_name(repo)}")
    |> @span.set_attribute("appsignal:category", "rollback.ecto")
    |> @tracer.close_span(end_time: time)

    # Close span created by `handle_begin/3`
    @tracer.close_span(current_span, end_time: time)
  end

  defp handle_query(current_span, total_time, repo, query) do
    time = :os.system_time()

    "http_request"
    |> @tracer.create_span(current_span, start_time: time - total_time)
    |> @span.set_name("Query #{module_name(repo)}")
    |> @span.set_attribute("appsignal:category", "query.ecto")
    |> @span.set_sql(query)
    |> @tracer.close_span(end_time: time)
  end
end
