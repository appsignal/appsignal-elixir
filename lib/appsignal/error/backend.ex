defmodule Appsignal.Error.Backend do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @behaviour :gen_event

  def init(opts), do: {:ok, opts}

  def handle_event({:error, gl, {_, _, _, metadata} = event}, state) when node(gl) == node() do
    {error, stacktrace} = metadata[:crash_reason]

    ""
    |> @tracer.create_span(nil, metadata[:pid])
    |> @span.add_error(error, stacktrace)
    |> @tracer.close_span()

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
