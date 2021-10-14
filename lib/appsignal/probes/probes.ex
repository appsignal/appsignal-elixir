defmodule Appsignal.Probes do
  @moduledoc false
  require Logger

  def register(name, probe) do
    spec = probe_spec(name, probe)

    :ok = unregister(name)

    case DynamicSupervisor.start_child(Appsignal.Probes.Supervisor, spec) do
      {:ok, _pid} -> :ok
      {:ok, _pid, _info} -> :ok
      other -> other
    end
  end

  def unregister(name) do
    Registry.dispatch(Appsignal.Probes.Registry, name, fn [{pid, _value}] ->
      DynamicSupervisor.terminate_child(Appsignal.Probes.Supervisor, pid)
    end)
  end

  defp probe_spec(name, probe) when is_function(probe) do
    probe_spec(name, {Appsignal.Probes.FunctionProbe, [[probe]]})
  end

  defp probe_spec(name, probe) when is_atom(probe) do
    probe_spec(name, {probe, [[]]})
  end

  defp probe_spec(name, {module, args}) do
    %{
      id: name,
      start: {
        module,
        :start_link,
        args ++
          [
            [name: {:via, Registry, {Appsignal.Probes.Registry, name}}]
          ]
      }
    }
  end
end
