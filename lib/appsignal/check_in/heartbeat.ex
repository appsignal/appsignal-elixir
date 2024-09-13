defmodule Appsignal.CheckIn.Heartbeat do
  use GenServer, shutdown: :brutal_kill

  @interval_milliseconds Application.compile_env(
                           :appsignal,
                           :appsignal_checkin_heartbeat_interval_milliseconds,
                           30_000
                         )

  @impl true
  def init(identifier) do
    {:ok, identifier, {:continue, :heartbeat}}
  end

  def start(identifier) do
    GenServer.start(__MODULE__, identifier)
  end

  def start_link(identifier) do
    GenServer.start_link(__MODULE__, identifier)
  end

  def heartbeat(identifier) do
    GenServer.cast(__MODULE__, {:heartbeat, identifier})
    :ok
  end

  @impl true
  def handle_continue(:heartbeat, identifier) do
    Appsignal.CheckIn.heartbeat(identifier)
    Process.send_after(self(), :heartbeat, @interval_milliseconds)
    {:noreply, identifier}
  end

  @impl true
  def handle_info(:heartbeat, identifier) do
    {:noreply, identifier, {:continue, :heartbeat}}
  end
end
