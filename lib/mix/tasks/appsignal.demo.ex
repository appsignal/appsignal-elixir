defmodule Mix.Tasks.Appsignal.Demo do
  use Mix.Task

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:appsignal)
    Appsignal.Demo.create_transaction_performance_request
    Appsignal.Demo.create_transaction_error_request
    Appsignal.stop(nil)
  end
end
