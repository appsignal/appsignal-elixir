defmodule Appsignal.ErrorLoggerHandler do
  require Logger
  alias Appsignal.ErrorHandler

  def init(state) do
    {:ok, state}
  end

  def handle_event({:error_report, _gleader, {pid, :crash_report, [report | _]}}, state) do
    try do
      {_kind, error, stack} = report[:error_info]
      ErrorHandler.handle_error(pid, error, stack)
    rescue
      exception ->
        Logger.warn(fn ->
          """
          AppSignal: Failed to match error report: #{Exception.message(exception)}
          #{inspect(report[:error_info])}
          """
        end)
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end
end
