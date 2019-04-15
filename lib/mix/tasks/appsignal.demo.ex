defmodule Mix.Tasks.Appsignal.Demo do
  require Logger
  use Mix.Task

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:appsignal)

    if Appsignal.Config.active?() do
      Appsignal.Demo.create_transaction_performance_request()
      Appsignal.Demo.create_transaction_error_request()
      Appsignal.stop(nil)
      Logger.info("Demonstration sample data sent!")

      Logger.info(
        "It may take about a minute for the data to appear on https://appsignal.com/accounts"
      )
    else
      Logger.error("""
      Error: Unable to start the AppSignal agent and send data to AppSignal.com.
      Please use the diagnose command (https://docs.appsignal.com/elixir/command-line/diagnose.html) to debug your configuration:

            MIX_ENV=prod mix appsignal.diagnose
      """)
    end
  end
end
