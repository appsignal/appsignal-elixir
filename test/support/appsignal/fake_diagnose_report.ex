defmodule Appsignal.Diagnose.FakeReport do
  @behaviour Appsignal.Diagnose.ReportBehaviour
  use TestAgent

  def send(_, report) do
    update(__MODULE__, :report_sent?, true)
    update(__MODULE__, :sent_report, report)

    get(__MODULE__, :response) || {:error, %{reason: "response not set"}}
  end
end
