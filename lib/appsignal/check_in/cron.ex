defmodule Appsignal.CheckIn.Cron do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron.Event

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
    @scheduler.schedule(Event.new(cron, :start))
  end

  @spec finish(Cron.t()) :: :ok
  def finish(cron) do
    @scheduler.schedule(Event.new(cron, :finish))
  end
end

defmodule Appsignal.CheckIn.Cron.Event do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron

  @derive Jason.Encoder

  @type kind :: :start | :finish
  @type t :: %Event{
          identifier: String.t(),
          digest: String.t(),
          kind: kind,
          timestamp: integer,
          check_in_type: :cron
        }

  defstruct [:identifier, :digest, :kind, :timestamp, :check_in_type]

  @spec new(Cron.t(), kind) :: t
  def new(%Cron{identifier: identifier, digest: digest}, kind) do
    %Event{
      identifier: identifier,
      digest: digest,
      kind: kind,
      timestamp: System.system_time(:second),
      check_in_type: :cron
    }
  end
end
