defmodule Appsignal.Error.Backend do
  @moduledoc false
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @behaviour :gen_event

  def init(opts), do: {:ok, opts}

  def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
    pid = metadata[:pid]

    case Keyword.get(metadata, :crash_reason) do
      {reason, stacktrace} ->
        span =
          case @tracer.lookup(pid) do
            [{_pid, :ignore}] ->
              :ok

            [] ->
              "background_job"
              |> @tracer.create_span(nil, pid: pid)
              |> set_error_data(reason, stacktrace)

            spans when is_list(spans) ->
              {_pid, span} = List.last(spans)
              set_error_data(span, reason, stacktrace)
          end

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_call(_event, state) do
    {:ok, :ok, state}
  end

  defp set_error_data(span, reason, stacktrace) do
    span
    |> @span.add_error(:error, reason, stacktrace)
    |> @tracer.close_span()
  end
end
