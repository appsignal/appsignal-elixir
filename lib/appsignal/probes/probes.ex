defmodule Appsignal.Probes do
  @moduledoc false
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(name, probe) do
    if genserver_running?() do
      if is_function(probe) do
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

  def unregister(name) do
    GenServer.cast(__MODULE__, name)
    :ok
  end

  def init([]) do
    schedule_probes()
    {:ok, %{}}
  end

  def handle_cast({name, probe}, probes) do
    if Map.has_key?(probes, name) do
      Logger.debug(fn -> "A probe with name '#{name}' already exists. Overriding that one." end)
    end

    {:noreply, Map.put(probes, name, probe)}
  end

  def handle_cast(name, probes) do
    {:noreply, Map.delete(probes, name)}
  end

  def handle_info(:run_probes, probes) do
    if Appsignal.Config.minutely_probes_enabled?() do
      Enum.each(probes, fn {name, probe} ->
        Task.start(fn ->
          try do
            probe.()
          rescue
            e ->
              Logger.error("Error while calling probe #{name}: #{inspect(e)}")
          end
        end)
      end)
    end

    schedule_probes()
    {:noreply, probes}
  end

  def child_spec(_) do
    %{
      id: Appsignal.Probes,
      start: {Appsignal.Probes, :start_link, []}
    }
  end

  defp genserver_running? do
    pid = Process.whereis(__MODULE__)
    !is_nil(pid) && Process.alive?(pid)
  end

  if Mix.env() in [:test, :test_no_nif] do
    defp schedule_probes do
      Process.send_after(self(), :run_probes, 10)
    end
  else
    defp schedule_probes do
      Process.send_after(self(), :run_probes, (60 - DateTime.utc_now().second) * 1000)
    end
  end
end
