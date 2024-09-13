defmodule Appsignal.CheckIn.Cron do
  alias __MODULE__
  alias Appsignal.CheckIn.Event

  @scheduler Application.compile_env(
               :appsignal,
               :appsignal_checkin_scheduler,
               Appsignal.CheckIn.Scheduler
             )
  @type t :: %Cron{identifier: String.t(), digest: String.t()}

  defstruct [:identifier, :digest]

  @spec new(String.t()) :: t
  def new(identifier) do
    %Cron{
      identifier: identifier,
      digest: random_digest()
    }
  end

  defp random_digest do
    Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end

  @spec start(Cron.t()) :: :ok
  def start(cron) do
    @scheduler.schedule(Event.cron(cron, :start))
  end

  @spec finish(Cron.t()) :: :ok
  def finish(cron) do
    @scheduler.schedule(Event.cron(cron, :finish))
  end
end
