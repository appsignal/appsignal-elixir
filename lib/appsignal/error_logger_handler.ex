defmodule Appsignal.ErrorLoggerHandler do
  @moduledoc """
  Error handler to send crash reports to AppSignal.

  AppSignal automatically adds `Appsignal.ErrorLoggerHandler` to Erlang's
  `:error_logger` as a report handler to receive error reports. It extracts the
  error and stacktrace from the report and sends it over to
  `Appsignal.ErrorHandler` to be reported to AppSignal.
  """

  require Logger

  @doc false
  def init(state) do
    {:ok, state}
  end

  @doc false
  def handle_event({:error_report, _gleader, {pid, :crash_report, [report | _]}}, state) do
    try do
      {_kind, error, stack} = report[:error_info]
      Appsignal.ErrorHandler.handle_error(pid, error, stack)
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

  @doc false
  def handle_event(_event, state) do
    {:ok, state}
  end

  @doc false
  def handle_info(_, state) do
    {:ok, state}
  end
end
