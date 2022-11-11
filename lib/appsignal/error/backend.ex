defmodule Appsignal.Error.Backend do
  @moduledoc false

  require Appsignal.Utils

  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @behaviour :gen_event

  require Logger

  def init(opts), do: {:ok, opts}

  def attach do
    case Logger.add_backend(Appsignal.Error.Backend) do
      {:error, error} -> Logger.warn("Appsignal.Error.Backend not attached to Logger: #{error}")
      _ -> Appsignal.IntegrationLogger.debug("Appsignal.Error.Backend attached to Logger")
    end
  end

  def handle_event({:error, gl, {_, _, _, metadata}}, state) when node(gl) == node() do
    metadata
    |> Enum.into(%{})
    |> handle_report()

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  defp handle_report(%{crash_reason: {reason, stacktrace}, conn: %{owner: pid}}) do
    pid
    |> @tracer.lookup()
    |> do_handle_report(pid, reason, stacktrace)
  end

  defp handle_report(%{crash_reason: {reason, stacktrace}, pid: pid, domain: domains}) do
    unless :cowboy in domains do
      pid
      |> @tracer.lookup()
      |> do_handle_report(pid, reason, stacktrace)
    end
  end

  defp handle_report(%{crash_reason: {reason, stacktrace}, pid: pid}) do
    pid
    |> @tracer.lookup()
    |> do_handle_report(pid, reason, stacktrace)
  end

  defp handle_report(_) do
    :ok
  end

  defp do_handle_report([{_pid, :ignore}], _, _, _) do
    :ok
  end

  defp do_handle_report([], pid, reason, stacktrace) do
    "background_job"
    |> @tracer.create_span(nil, pid: pid)
    |> set_error_data(reason, stacktrace)
  end

  defp do_handle_report(spans, _, reason, stacktrace) when is_list(spans) do
    {_pid, span} = List.last(spans)

    set_error_data(span, reason, stacktrace)
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
end
