defmodule Mix.Tasks.Appsignal.Demo do
  use Mix.Task

  @shortdoc "Perform and send a demonstration error and performance issue to AppSignal."

  def run(_args) do
    Appsignal.Demo.transmit
  end
end
