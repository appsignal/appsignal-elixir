defmodule Appsignal.Telemetry do
  @moduledoc false

  # Keeps the span a handler opens for a `:telemetry` start event, so that the
  # handler for the matching stop or exception event can take that span rather
  # than the process's current one. `:telemetry` emits a span's start, stop and
  # exception events in the same process, so the spans are kept in the process
  # dictionary.
  #
  # A correlated span is kept under the `telemetry_span_context` that
  # `:telemetry.span/3` puts in the metadata of all three events. Stacked spans
  # are kept last in, first out per handler, for events without one. A start
  # that opened no span keeps `nil`, so that its stop takes nothing.

  def attach(module, handlers) do
    for {event, fun} <- handlers do
      id = {module, event}
      detach = :telemetry.detach(id)

      case {detach, :telemetry.attach(id, event, &__MODULE__.handle_event/4, {id, fun})} do
        {:ok, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "#{inspect(module)} reattached to #{inspect(event)}"
            )

          :ok

        {{:error, :not_found}, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug("#{inspect(module)} attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Appsignal.IntegrationLogger.warn(
            "#{inspect(module)} not attached to #{inspect(event)}: #{inspect(error)}"
          )

          error
      end
    end
  end

  # `:telemetry` detaches a handler for good when it raises, so the rest of
  # the application's events would go uninstrumented. A raising handler stays
  # attached instead.
  @doc false
  def handle_event(event, measurements, metadata, {id, fun}) do
    fun.(event, measurements, metadata, :ok)
  catch
    kind, reason ->
      stacktrace = __STACKTRACE__
      log_failure(id, event, kind, reason, stacktrace)
      report_failure(id, event, kind, reason, stacktrace)
  end

  defp log_failure(id, event, kind, reason, stacktrace) do
    message =
      "#{inspect(elem(id, 0))} failed to handle #{inspect(event)}: " <>
        Exception.format(kind, reason, stacktrace)

    if :persistent_term.get({__MODULE__, :failed, id}, false) do
      Appsignal.IntegrationLogger.debug(message)
    else
      :persistent_term.put({__MODULE__, :failed, id}, true)
      Appsignal.IntegrationLogger.error(message)
    end
  end

  # Only the test suite listens for this event, to fail a test whose handler
  # raised. It has the metadata of `[:telemetry, :handler, :failure]`.
  if Application.compile_env(:appsignal, :report_handler_failures, false) do
    defp report_failure(id, event, kind, reason, stacktrace) do
      :telemetry.execute(
        [:appsignal, :handler, :failure],
        %{monotonic_time: System.monotonic_time(), system_time: System.system_time()},
        %{handler_id: id, event_name: event, kind: kind, reason: reason, stacktrace: stacktrace}
      )
    end
  else
    defp report_failure(_id, _event, _kind, _reason, _stacktrace), do: :ok
  end

  def put_span(id, %{telemetry_span_context: context}, span),
    do: put_correlated_span(id, context, span)

  def put_span(id, _metadata, span), do: put_stacked_span(id, span)

  def get_span(id, %{telemetry_span_context: context}), do: get_correlated_span(id, context)
  def get_span(id, _metadata), do: get_stacked_span(id)

  def take_span(id, %{telemetry_span_context: context}), do: take_correlated_span(id, context)
  def take_span(id, _metadata), do: take_stacked_span(id)

  def put_correlated_span(id, context, span) do
    Process.put({__MODULE__, id, context}, span)
    span
  end

  def get_correlated_span(id, context), do: Process.get({__MODULE__, id, context})

  def take_correlated_span(id, context), do: Process.delete({__MODULE__, id, context})

  def put_stacked_span(id, span) do
    Process.put({__MODULE__, id}, [span | Process.get({__MODULE__, id}, [])])
    span
  end

  def get_stacked_span(id) do
    case Process.get({__MODULE__, id}, []) do
      [span | _] -> span
      [] -> nil
    end
  end

  def take_stacked_span(id) do
    case Process.get({__MODULE__, id}, []) do
      [span] ->
        Process.delete({__MODULE__, id})
        span

      [span | rest] ->
        Process.put({__MODULE__, id}, rest)
        span

      [] ->
        nil
    end
  end

  # Newest first.
  def take_stacked_spans(id) do
    case Process.delete({__MODULE__, id}) do
      nil -> []
      spans -> Enum.reject(spans, &is_nil/1)
    end
  end
end
