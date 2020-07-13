defmodule Mix.Tasks.Appsignal.Demo do
  use Mix.Task
  require Logger

  def run(_) do
    Application.ensure_all_started(:appsignal)

    if Appsignal.Config.active?() do
      Appsignal.Demo.send_performance_sample()
      Appsignal.Demo.send_error_sample()

      Logger.info("""
      Demonstration sample data sent!

      It may take about a minute for the data to appear on https://appsignal.com/accounts
      """)
    else
      Logger.error("""
      Error: Unable to start the AppSignal agent and send data to AppSignal.com.
      Please use the diagnose command (https://docs.appsignal.com/elixir/command-line/diagnose.html) to debug your configuration:

            MIX_ENV=prod mix appsignal.diagnose
      """)
    end

    Appsignal.Nif.stop()
  end
end
