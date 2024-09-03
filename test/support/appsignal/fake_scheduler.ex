defmodule Appsignal.FakeScheduler do
  use Agent

  def start_link(opts \\ nil) do
    Agent.start_link(
      fn -> %{is_proxy: opts == :proxy, scheduled: []} end,
      name: __MODULE__
    )
  end

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def schedule(event) do
    if proxy?() do
      Appsignal.CheckIn.Scheduler.schedule(event)
    else
      Agent.update(__MODULE__, fn state ->
        %{state | scheduled: [event | state.scheduled]}
      end)

      :ok
    end
  end

  def scheduled do
    Agent.get(__MODULE__, &Enum.reverse(&1.scheduled))
  end

  defp proxy? do
    Agent.get(__MODULE__, & &1.is_proxy)
  end
end
