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
end
