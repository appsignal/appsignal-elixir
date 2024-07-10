defmodule Appsignal.CheckIn do
  alias Appsignal.CheckIn.Cron

  @spec cron(String.t()) :: :ok
  def cron(name) do
    Cron.finish(Cron.new(name))
  end

  @spec cron(String.t(), (-> out)) :: out when out: var
  def cron(name, fun) do
    cron = Cron.new(name)

    Cron.start(cron)
    output = fun.()
    Cron.finish(cron)

    output
  end
end

defmodule Appsignal.CheckIn.Cron do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron.Event

  @transmitter Application.compile_env(
                 :appsignal,
                 :appsignal_transmitter,
                 Appsignal.Transmitter
               )
  @type t :: %Cron{name: String.t(), id: String.t()}

  defstruct [:name, :id]

  @spec new(String.t()) :: t
  def new(name) do
    %Cron{
      name: name,
      id: random_id()
    }
  end

  defp random_id do
    Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end

  @spec start(Cron.t()) :: :ok
  def start(cron) do
    transmit(Event.new(cron, :start))
  end

  @spec finish(Cron.t()) :: :ok
  def finish(cron) do
    transmit(Event.new(cron, :finish))
  end

  @spec transmit(Event.t()) :: :ok
  defp transmit(event) do
    if Appsignal.Config.active?() do
      config = Appsignal.Config.config()
      endpoint = "#{config[:logging_endpoint]}/checkins/cron/json"

      case @transmitter.transmit(endpoint, event, config) do
        {:ok, status_code, _, _} when status_code in 200..299 ->
          Appsignal.IntegrationLogger.trace(
            "Transmitted cron check-in `#{event.name}` (#{event.id}) #{event.kind} event"
          )

        {:ok, status_code, _, _} ->
          Appsignal.IntegrationLogger.error(
            "Failed to transmit cron check-in #{event.kind} event: status code was #{status_code}"
          )

        {:error, reason} ->
          Appsignal.IntegrationLogger.error(
            "Failed to transmit cron check-in #{event.kind} event: #{reason}"
          )
      end
    else
      Appsignal.IntegrationLogger.debug(
        "AppSignal not active, not transmitting cron check-in event"
      )
    end

    :ok
  end
end

defmodule Appsignal.CheckIn.Cron.Event do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron

  @derive Jason.Encoder

  @type kind :: :start | :finish
  @type t :: %Event{name: String.t(), id: String.t(), kind: kind, timestamp: integer}

  defstruct [:name, :id, :kind, :timestamp]

  @spec new(Cron.t(), kind) :: t
  def new(%Cron{name: name, id: id}, kind) do
    %Event{
      name: name,
      id: id,
      kind: kind,
      timestamp: System.system_time(:second)
    }
  end
end
