defmodule Appsignal.Probes do
  @moduledoc false
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{}}
  end

  def register(name, probe) do
    spec =
      if is_function(probe) do
        {Appsignal.Probes.FunctionProbeWrapper, [probe]}
      else
        probe
      end

    GenServer.cast(__MODULE__, {:register, {name, spec}})
  end

  def unregister(name) do
    GenServer.cast(__MODULE__, {:unregister, name})
  end

  def handle_cast({:register, {name, spec}}, probes) do
    if Map.has_key?(probes, name) do
      Logger.debug(fn -> "A probe with name '#{name}' already exists. Terminating that one." end)
      do_unregister(probes, name)
    end

    do_register(probes, name, spec)
  end

  def handle_cast({:unregister, name}, probes) do
    do_unregister(probes, name)

    {:noreply, Map.delete(probes, name)}
  end

  defp do_register(probes, name, spec) do
    case DynamicSupervisor.start_child(Appsignal.Probes.DynamicSupervisor, spec) do
      {:ok, pid} -> {:noreply, Map.put(probes, name, pid)}
      {:error, error} -> raise(error)
    end
  end

  defp do_unregister(probes, name) do
    with {:ok, pid} <- Map.fetch(probes, name) do
      DynamicSupervisor.terminate_child(Appsignal.Probes.DynamicSupervisor, pid)
    end
  end

  def child_spec(_) do
    %{
      id: Appsignal.Probes,
      start: {Appsignal.Probes, :start_link, []}
    }
  end
end
