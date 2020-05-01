defmodule Appsignal.Error.Backend do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @behaviour :gen_event

  def init(opts), do: {:ok, opts}

  def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
    pid = metadata[:pid]

    case Keyword.get(metadata, :crash_reason) do
      {reason, stacktrace} ->
        span =
          case @tracer.current_span(pid) do
            nil -> @tracer.create_span("background_job", nil, pid)
            current -> current
          end

        span
        |> @span.add_error(:error, reason, stacktrace)
        |> @tracer.close_span()

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
