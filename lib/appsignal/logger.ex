defmodule Appsignal.Logger do
  require Logger
  @logger Application.get_env(:appsignal, :logger, Logger)

  def debug(log) do
    Appsignal.Config.debug?() && @logger.debug(log)
  end
end
