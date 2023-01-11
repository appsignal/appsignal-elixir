defmodule Appsignal.Oban do
  require Appsignal.Utils

  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @appsignal Appsignal.Utils.compile_env(:appsignal, :appsignal, Appsignal)

  @moduledoc false

  require Logger

  def attach do
    handlers = %{
      [:oban, :job, :start] => &__MODULE__.oban_job_start/4,
      [:oban, :job, :stop] => &__MODULE__.oban_job_stop/4,
      [:oban, :job, :exception] => &__MODULE__.oban_job_exception/4,
      [:oban, :engine, :insert_job, :start] => &__MODULE__.oban_insert_job_start/4,
      [:oban, :engine, :insert_job, :stop] => &__MODULE__.oban_insert_job_stop/4,
      [:oban, :engine, :insert_job, :exception] => &__MODULE__.oban_insert_job_stop/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Oban attached to #{inspect(event)}")

          :ok

        {:error, _} = error ->
          Logger.warn("Appsignal.Oban not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def oban_job_start(
        _event,
        _measurements,
        %{job: job},
        _config
      ) do
    span = @tracer.create_span("oban")

    span
    |> @span.set_name(to_string(job.worker))
    |> @span.set_sample_data("params", job.args)
    |> @span.set_attribute("id", job.id)
    |> @span.set_attribute("queue", to_string(job.queue))
    |> @span.set_attribute("attempt", job.attempt)
    |> @span.set_attribute("priority", job.priority)
    |> @span.set_attribute("appsignal:category", "job.oban")

    for {key, value} <- job.tags do
      @span.set_attribute(span, "job_tag_#{key}", value)
    end

    add_job_queue_time_value(job)
  end

  def oban_job_stop(
        _event,
        %{duration: duration},
        %{state: state, result: result, job: job},
        _config
      ) do
    @tracer.current_span()
    |> @span.set_attribute("state", to_string(state))
    |> @span.set_attribute("result", inspect(result))
    |> @tracer.close_span()

    increment_job_stop_counter(job, state)

    add_job_duration_value(job, duration, state)
  end

  def oban_job_exception(_event, %{duration: duration}, metadata, _config) do
    span =
      @tracer.current_span()
      |> @span.set_attribute("state", to_string(metadata[:state]))
      |> @span.set_attribute("worker", to_string(metadata[:job].worker))

    if Map.has_key?(metadata, :kind) and Map.has_key?(metadata, :reason) and
         Map.has_key?(metadata, :stacktrace) do
      @span.add_error(span, metadata[:kind], metadata[:reason], metadata[:stacktrace])
    end

    @tracer.close_span(span)

    increment_job_stop_counter(metadata[:job], metadata[:state])

    add_job_duration_value(metadata[:job], duration, metadata[:state])
  end

  def oban_insert_job_start(_event, _measurements, metadata, _config) do
    span = @tracer.create_span("oban", @tracer.current_span)

    @span.set_attribute(span, "appsignal:category", "insert_job.oban")

    case metadata[:changeset] do
      %{changes: %{worker: worker}} ->
        @span.set_name(span, "Insert job (#{worker})")

      _ ->
        @span.set_name(span, "Insert job")
    end
  end

  def oban_insert_job_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  defp increment_job_stop_counter(job, state) do
    tag_combinations = [
      %{worker: to_string(job.worker), queue: to_string(job.queue), state: to_string(state)},
      %{worker: to_string(job.worker), state: to_string(state)},
      %{queue: to_string(job.queue), state: to_string(state)},
      %{state: to_string(state)}
    ]

    Enum.each(tag_combinations, fn tags ->
      @appsignal.increment_counter("oban_job_count", 1, tags)
    end)
  end

  defp add_job_duration_value(job, duration, state) do
    tag_combinations = [
      %{worker: to_string(job.worker), state: to_string(state)},
      %{worker: to_string(job.worker), hostname: Appsignal.Utils.Hostname.hostname()},
      %{worker: to_string(job.worker)}
    ]

    Enum.each(tag_combinations, fn tags ->
      @appsignal.add_distribution_value(
        "oban_job_duration",
        System.convert_time_unit(duration, :native, :millisecond),
        tags
      )
    end)
  end

  defp add_job_queue_time_value(job) do
    delay = DateTime.diff(job.attempted_at, job.scheduled_at, :millisecond)

    @appsignal.add_distribution_value("oban_job_queue_time", delay, %{
      queue: to_string(job.queue)
    })
  end
end
