defmodule Appsignal.Diagnose.FakeReport do
  @behaviour Appsignal.Diagnose.ReportBehaviour

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def set(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def send(_, report) do
    Agent.update(__MODULE__, &Map.put(&1, :report_sent?, true))
    Agent.update(__MODULE__, &Map.put(&1, :sent_report, report))
    get(:response) || {:error, %{reason: "response not set"}}
  end
end
