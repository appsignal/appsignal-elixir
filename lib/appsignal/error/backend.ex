defmodule Appsignal.Error.Backend do
  @moduledoc false
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @behaviour :gen_event

  require Logger

  def init(opts), do: {:ok, opts}

  def attach do
    case ok?(Logger.add_backend(Appsignal.Error.Backend)) do
      :ok -> Logger.debug("Appsignal.Error.Backend attached to Logger")
      error -> Logger.warn("Appsignal.Error.Backend not attached to Logger: #{inspect(error)}")
    end
  end

  def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
    pid = metadata[:pid]

    case Keyword.get(metadata, :crash_reason) do
      {reason, stacktrace} ->
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

  def handle_info(_message, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp set_error_data(span, reason, stacktrace) do
    span
    |> @span.add_error(:error, reason, stacktrace)
    |> @tracer.close_span()
  end

  defp ok?({:ok, _, _}), do: :ok
  defp ok?({:ok, _}), do: :ok
  defp ok?(error), do: error
end
