defmodule Appsignal.ProbesRegistry do
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register({name, probe}) do
    if genserver_running?() do
      Logger.debug(fn -> "Adding probe #{name}" end)
      GenServer.cast(__MODULE__, {name, probe})
      :ok
    else
      Logger.error("Probe registry is not running")
      nil
    end
  end

  def init([]) do
    register({:test_probe, Appsignal.TestProbe})
    schedule_probes()
    {:ok, %{}}
  end

  def handle_cast({name, probe}, probes) do
    new_probes =
      if :erlang.function_exported(probe, :call, 0) do
        if Map.has_key?(probes, name) do
          Logger.debug(fn -> "A probe with name '#{name}' already exists. Overriding that one" end)
        end

        Map.put(probes, name, probe)
      else
        Logger.error(
          "Trying to register probe #{name}. Ignoring probe since it does not export .call/0"
        )
      end

    {:noreply, new_probes}
  end

  def handle_info(:run_probes, probes) do
    Logger.debug(fn -> "Running #{Enum.count(probes)} probes" end)

    Enum.each(probes, fn {name, probe} ->
      Logger.debug(fn -> "Creating task for #{name}" end)

      Task.start(fn ->
        try do
          probe.call
        rescue
          _ ->
            Logger.error("Error while calling probe #{name}")
        end
      end)
    end)

    schedule_probes()
    {:noreply, probes}
  end

  defp genserver_running? do
    pid = Process.whereis(__MODULE__)
    !is_nil(pid) && Process.alive?(pid)
  end

  defp schedule_probes() do
    Process.send_after(self(), :run_probes, 60 * 1000)
  end
end
