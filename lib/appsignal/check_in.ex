defmodule Appsignal.CheckIn do
  alias Appsignal.CheckIn.Cron

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
end

defmodule Appsignal.CheckIn.Cron do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron.Event

  @transmitter Application.compile_env(
                 :appsignal,
                 :appsignal_transmitter,
                 Appsignal.Transmitter
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
      endpoint = "#{config[:logging_endpoint]}/check_ins/json"

      case @transmitter.transmit(endpoint, {event, :json}, config) do
        {:ok, status_code, _, _} when status_code in 200..299 ->
          Appsignal.IntegrationLogger.trace(
            "Transmitted cron check-in `#{event.identifier}` (#{event.digest}) #{event.kind} event"
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
