defmodule Appsignal.Probes do
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(name, probe) do
    if genserver_running?() do
      if is_function(probe) do
        Logger.debug(fn -> "Adding probe #{name}" end)
        GenServer.cast(__MODULE__, {name, probe})
        :ok
      else
        Logger.debug(fn ->
          "Trying to register probe #{name}. Ignoring probe since it's not a function."
        end)

        {:error, "Probe is not a function"}
      end
    else
      {:error, "Probe genserver is not running"}
    end
  end

  def init([]) do
    schedule_probes()
    {:ok, %{}}
  end

  def handle_cast({name, probe}, probes) do
    if Map.has_key?(probes, name) do
      Logger.debug(fn -> "A probe with name '#{name}' already exists. Overriding that one" end)
    end

    {:noreply, Map.put(probes, name, probe)}
  end

  def handle_info(:run_probes, probes) do
    Logger.debug(fn -> "Running #{Enum.count(probes)} probes" end)

    Enum.each(probes, fn {name, probe} ->
      Logger.debug(fn -> "Creating task for #{name}" end)

      Task.start(fn ->
        try do
          probe.()
        rescue
          e ->
            Logger.error("Error while calling probe #{name}: #{e}")
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

  defp schedule_probes do
    Process.send_after(self(), :run_probes, 60 * 1000)
  end
end
