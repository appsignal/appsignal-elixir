defmodule Appsignal.LoggerHandler do
  @moduledoc """
  Error handler to send crash reports to AppSignal.

  AppSignal automatically adds `Appsignal.LoggerHandler` to Erlang's `:error`
  as a report handler to receive error reports. It extracts the error and
  stacktrace from the report and sends it over to `Appsignal.ErrorHandler` to
  be reported to AppSignal.
  """

  require Logger

  @doc false
  def log(
        %{
          meta: %{error_logger: %{tag: :error_report, type: :crash_report}},
          msg: {:report, %{report: [report | _]}}
        },
        _config
      ) do
    try do
      {_kind, error, stack} = report[:error_info]
      Appsignal.ErrorHandler.handle_error(self(), error, stack)
    rescue
      exception ->
        Logger.warn(fn ->
          """
          AppSignal: Failed to match error report: #{Exception.message(exception)}
          #{inspect(report[:error_info])}
          """
        end)
    end
  end

  def log(_log, _config) do
    :ok
  end
end
