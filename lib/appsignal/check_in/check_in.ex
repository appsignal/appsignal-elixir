defmodule Appsignal.CheckIn do
  alias Appsignal.CheckIn.Cron
  alias Appsignal.CheckIn.Event

  @scheduler Application.compile_env(
               :appsignal,
               :appsignal_checkin_scheduler,
               Appsignal.CheckIn.Scheduler
             )

  @spec cron(String.t()) :: :ok
  def cron(identifier) do
    Cron.finish(Cron.new(identifier))
  end

  @spec cron(String.t(), (-> out)) :: out when out: var
  def cron(identifier, fun) do
    cron = Cron.new(identifier)

    Cron.start(cron)
    output = fun.()
    Cron.finish(cron)

    output
  end

  @spec heartbeat(String.t()) :: :ok
  @spec heartbeat(String.t(), continuous: boolean) :: :ok
  def heartbeat(identifier) do
    @scheduler.schedule(Event.heartbeat(identifier))
    :ok
  end

  def heartbeat(identifier, continuous: true) do
    Appsignal.CheckIn.Heartbeat.start_link(identifier)
    :ok
  end

  def heartbeat(identifier, _), do: heartbeat(identifier)
end
