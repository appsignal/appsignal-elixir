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
        GenServer.cast(__MODULE__, {:register, {name, {Appsignal.Probes.FunctionProbeWrapper, [probe]}}})
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
    GenServer.cast(__MODULE__, {:unregister, name})
    :ok
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_cast({:register, {name, probe}}, probes) do
    if Map.has_key?(probes, name) do
      Logger.debug(fn -> "A probe with name '#{name}' already exists. Overriding that one." end)
    end

    {:ok, pid} = DynamicSupervisor.start_child(Appsignal.Probes.DynamicSupervisor, probe)

    {:noreply, Map.put(probes, name, pid)}
  end

  def handle_cast({:unregister, name}, probes) do
    with {:ok, pid} <- Map.fetch(probes, name) do
      DynamicSupervisor.terminate_child(Appsignal.Probes.DynamicSupervisor, pid)
    end

    {:noreply, Map.delete(probes, name)}
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
end
