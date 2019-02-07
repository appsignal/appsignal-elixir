defmodule Appsignal.ErrorLoggerHandler do
  require Logger
  alias Appsignal.ErrorHandler

  def init(state) do
    {:ok, state}
  end

  def handle_event({:error_report, _gleader, {pid, :crash_report, [report | _]}}, state) do
    case match_report(report) do
      {error, stack} ->
        ErrorHandler.handle_error(pid, error, stack)

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp match_report(report) do
    try do
      {_kind, error, stack} = report[:error_info]
      {error, stack}
    rescue
      exception ->
        Logger.warn(fn ->
          """
          AppSignal: Failed to match error report: #{Exception.message(exception)}
          #{inspect(report[:error_info])}
          """
        end)

        :nomatch
    end
  end
end
