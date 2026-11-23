defmodule Appsignal.Telemetry do
  @moduledoc false

  # Keeps the span a handler opens for a `:telemetry` start event, so that the
  # handler for the matching stop or exception event closes that span rather
  # than the process's current one. `:telemetry` emits a span's start, stop and
  # exception events in the same process. Events are matched by their
  # `telemetry_span_context` when they have one, and otherwise last in, first
  # out per handler.

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)

  def put_span(id, %{telemetry_span_context: context}, span) do
    Process.put({__MODULE__, id, context}, span)
    span
  end

  def put_span(id, _metadata, span) do
    Process.put({__MODULE__, id}, [span | Process.get({__MODULE__, id}, [])])
    span
  end

  def get_span(id, %{telemetry_span_context: context}) do
    Process.get({__MODULE__, id, context})
  end

  def get_span(id, _metadata) do
    case Process.get({__MODULE__, id}, []) do
      [span | _] -> span
      [] -> nil
    end
  end

  def close_span(id, metadata) do
    case take_span(id, metadata) do
      nil -> nil
      span -> @tracer.close_all(span)
    end
  end

  def take_span(id, %{telemetry_span_context: context}) do
    Process.delete({__MODULE__, id, context})
  end

  def take_span(id, _metadata) do
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
