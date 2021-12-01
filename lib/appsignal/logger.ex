defmodule Appsignal.Logger do
  require Logger
  require Appsignal.Utils

  @logger Appsignal.Utils.compile_env(:appsignal, :logger, Logger)

  @spec debug(any()) :: :ok
  @doc """
  Passes the debug message to `Logger.debug/1` if `Appsignal.Config.debug?/0`
  is `true`.
  """
  def debug(log) do
    Appsignal.Config.debug?() && @logger.debug(log)
    :ok
  end
end
