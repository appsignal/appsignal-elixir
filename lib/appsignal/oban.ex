defmodule Appsignal.Oban do
  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @appsignal Application.compile_env(:appsignal, :appsignal, Appsignal)

  @moduledoc false

  def attach do
    exception_handler =
      case Appsignal.Config.report_oban_errors() do
        "all" -> &__MODULE__.oban_job_exception/4
        "discard" -> &__MODULE__.oban_job_discard/4
        "none" -> &__MODULE__.oban_job_stop/4
      end

    handlers = %{
      [:oban, :job, :start] => &__MODULE__.oban_job_start/4,
      [:oban, :job, :stop] => &__MODULE__.oban_job_stop/4,
      [:oban, :job, :exception] => exception_handler,
      [:oban, :engine, :insert_job, :start] => &__MODULE__.oban_insert_job_start/4,
      [:oban, :engine, :insert_job, :stop] => &__MODULE__.oban_insert_job_stop/4,
      [:oban, :engine, :insert_job, :exception] => &__MODULE__.oban_insert_job_stop/4
    }

    for {event, fun} <- handlers do
      detach = :telemetry.detach({__MODULE__, event})
      attach = :telemetry.attach({__MODULE__, event}, event, fun, :ok)

      case {detach, attach} do
        {:ok, :ok} ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Oban reattached to #{inspect(event)}")

          :ok

        {{:error, :not_found}, :ok} ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Oban attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Logger.warning("Appsignal.Oban not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def oban_job_start(
        _event,
        _measurements,
        %{
          id: id,
          args: args,
          queue: queue,
          worker: worker,
          attempt: attempt
        } = metadata,
        _config
      ) do
    span = @tracer.create_span("oban")

    span
    |> @span.set_name("#{to_string(worker)}#perform")
    |> @span.set_sample_data("params", args)
    |> @span.set_attribute("id", id)
    |> @span.set_attribute("queue", to_string(queue))
    |> @span.set_attribute("attempt", attempt)
    |> @span.set_attribute("worker", to_string(worker))
    |> @span.set_attribute("appsignal:category", "job.oban")

    # The `:conf` metadata key was added in Oban v2.4.0.
    conf = metadata[:conf]

    if conf && Map.get(conf, :prefix) do
      @span.set_attribute(span, "prefix", Map.get(conf, :prefix))
    end

    # The `:job` metadata key was added in Oban v2.3.1.
    job = metadata[:job]

    if job do
      @span.set_attribute(span, "priority", job.priority)

      add_job_queue_time_value(job, queue)

      set_job_meta_attributes(span, job)
    end

    # The `:tags` metadata key was added in v2.1.0.
    for tag <- Map.get(metadata, :tags, []) do
      @span.set_attribute(span, "job_tag_#{tag}", true)
    end
  end

  def oban_job_stop(
        _event,
        %{duration: duration},
        %{
          worker: worker,
          queue: queue
        } = metadata,
        _config
      ) do
    # The `:state` metadata key was added in Oban v2.4.0.
    # If not present, assume the job succeeded.
    state = Map.get(metadata, :state, "success")

    span =
      @tracer.current_span()
      |> @span.set_attribute("state", to_string(state))

    # The `:result` metadata key was added in Oban v2.5.0.
    # This refers to the Oban.Worker 'result' type that controls whether a job
    # is treated as a success or a failure.
    if Map.has_key?(metadata, :result) do
      {result, reason} = oban_result_and_reason(metadata[:result])

      @span.set_attribute(span, "result", result)

      if reason do
        @span.set_attribute(span, "result_reason", reason)
      end
    end

    @tracer.close_span(span)

    increment_job_stop_counter(worker, queue, state)

    add_job_duration_value(worker, duration, state)
  end

  def oban_job_exception(
        _event,
        %{duration: duration},
        %{
          worker: worker,
          queue: queue,
          kind: kind,
          error: reason,
          stacktrace: stacktrace
        } = metadata,
        _config
      ) do
    # The `:state` metadata key was added in Oban v2.4.0.
    # If not present, assume the job failed.
    state = Map.get(metadata, :state, "failure")

    span =
      @tracer.current_span()
      |> @span.set_attribute("state", to_string(state))

    @span.add_error(span, kind, reason, stacktrace)

    @tracer.close_span(span)

    increment_job_stop_counter(worker, queue, state)

    add_job_duration_value(worker, duration, state)
  end

  def oban_job_discard(event, measurements, metadata, config) do
    # The `:state` metadata key was added in Oban v2.4.0.
    # If not present, assume the job was discarded.
    state = Map.get(metadata, :state, "discard")

    if to_string(state) == "discard" do
      oban_job_exception(event, measurements, metadata, config)
    else
      oban_job_stop(event, measurements, metadata, config)
    end
  end

  def oban_insert_job_start(_event, _measurements, metadata, _config) do
    do_oban_insert_job_start(@tracer.current_span, metadata)
  end

  def do_oban_insert_job_start(nil, _metadata), do: nil

  def do_oban_insert_job_start(current_span, metadata) do
    span = @tracer.create_span("oban", current_span)

    @span.set_attribute(span, "appsignal:category", "insert_job.oban")

    case metadata[:changeset] do
      %{changes: %{worker: worker}} ->
        @span.set_name(span, "Insert job (#{worker})")

      _ ->
        # The changeset containing the worker appears in the metadata for
        # this event in every version where this event is emitted (from
        # v2.11.0 until v2.13.6, latest at the time of writing) but it's
        # undocumented. To be safe, account for it not being present.
        @span.set_name(span, "Insert job")
    end
  end

  def oban_insert_job_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  defp increment_job_stop_counter(worker, queue, state) do
    tag_combinations = [
      %{worker: to_string(worker), queue: to_string(queue), state: to_string(state)},
      %{worker: to_string(worker), state: to_string(state)},
      %{queue: to_string(queue), state: to_string(state)},
      %{state: to_string(state)}
    ]

    Enum.each(tag_combinations, fn tags ->
      @appsignal.increment_counter("oban_job_count", 1, tags)
    end)
  end

  defp add_job_duration_value(worker, duration, state) do
    tag_combinations = [
      %{worker: to_string(worker), state: to_string(state)},
      %{worker: to_string(worker), hostname: Appsignal.Utils.Hostname.hostname()},
      %{worker: to_string(worker)}
    ]

    Enum.each(tag_combinations, fn tags ->
      @appsignal.add_distribution_value(
        "oban_job_duration",
        System.convert_time_unit(duration, :native, :millisecond),
        tags
      )
    end)
  end

  defp add_job_queue_time_value(job, queue) do
    delay = DateTime.diff(job.attempted_at, job.scheduled_at, :millisecond)

    @appsignal.add_distribution_value("oban_job_queue_time", delay, %{
      queue: to_string(queue)
    })
  end

  defp set_job_meta_attributes(span, job) do
    for {key, value} <- job.meta do
      value =
        cond do
          is_binary(value) or is_number(value) or is_boolean(value) ->
            value

          is_atom(value) ->
            inspect(value)

          true ->
            nil
        end

      if value do
        @span.set_attribute(span, "job_meta_#{key}", value)
      end
    end
  end

  defp oban_result_and_reason(result_value) do
    case result_value do
      :ok -> {"ok", nil}
      :discard -> {"discard", nil}
      {:cancel, reason} -> {"cancel", oban_map_reason(reason)}
      {:discard, reason} -> {"discard", oban_map_reason(reason)}
      {:ok, _} -> {:ok, nil}
      {:error, reason} -> {"error", oban_map_reason(reason)}
      {:snooze, reason} -> {"snooze", oban_map_reason(reason)}
      # A job can technically return anything that's not a valid Oban.Worker 'result' type.
      # Account for this here and consider it a success, like Oban does.
      _ -> {"ok", nil}
    end
  end

  defp oban_map_reason(value) do
    case value do
      v when is_binary(v) ->
        v

      v when is_integer(v) or is_float(v) or is_boolean(v) or is_atom(v) ->
        to_string(v)

      _ ->
        inspect(value)
    end
  end
end
