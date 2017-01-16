defmodule Mix.Tasks.Appsignal.Demo do
  require Logger
  use Mix.Task

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:appsignal)
    Appsignal.Demo.create_transaction_performance_request
    Appsignal.Demo.create_transaction_error_request
    Appsignal.stop(nil)
    Logger.info("Demonstration sample data sent!")
    Logger.info("It may take about a minute for the data to appear on AppSignal.com/accounts")
  end
end
