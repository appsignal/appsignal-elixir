defmodule Appsignal.Error.Backend do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)

  @behaviour :gen_event

  def init(opts), do: {:ok, opts}

  def handle_event({:error, gl, {_, _, _, metadata} = event}, state) when node(gl) == node() do
    @tracer.create_span("", nil, metadata[:pid])

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
