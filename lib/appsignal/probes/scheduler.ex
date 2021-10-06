defmodule Appsignal.Probes.Scheduler do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    schedule_probes()
    {:ok, nil}
  end

  def handle_info(:run_probes, _state) do
    if Appsignal.Config.minutely_probes_enabled?() do
      do_run_probes()
    end

    schedule_probes()
    {:noreply, nil}
  end

  defp do_run_probes do
    children = DynamicSupervisor.which_children(Appsignal.Probes.Supervisor)

    Enum.each(children, fn {_id, pid, _type, _modules} ->
      if is_pid(pid) do
        GenServer.cast(pid, :probe)
      end
    end)
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
