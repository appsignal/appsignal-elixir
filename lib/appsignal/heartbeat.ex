defmodule Appsignal.Heartbeat do
  alias __MODULE__
  alias Appsignal.Heartbeat.Event
  require Appsignal.Utils

  @transmitter Appsignal.Utils.compile_env(
                 :appsignal,
                 :appsignal_transmitter,
                 Appsignal.Transmitter
               )
  @type t :: %Heartbeat{name: String.t(), id: String.t()}

  defstruct [:name, :id]

  @spec new(String.t()) :: t
  def new(name) do
    %Appsignal.Heartbeat{
      name: name,
      id: random_id()
    }
  end

  defp random_id do
    Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end

  @spec start(Heartbeat.t()) :: :ok
  def start(heartbeat) do
    transmit(Event.new(heartbeat, :start))
  end

  @spec finish(Heartbeat.t()) :: :ok
  def finish(heartbeat) do
    transmit(Event.new(heartbeat, :finish))
  end

  @spec heartbeat(String.t()) :: :ok
  def heartbeat(name) do
    finish(Heartbeat.new(name))
  end

  @spec heartbeat(String.t(), (-> out)) :: out when out: var
  def heartbeat(name, fun) do
    heartbeat = Heartbeat.new(name)

    start(heartbeat)
    output = fun.()
    finish(heartbeat)

    output
  end

  @spec transmit(Event.t()) :: :ok
  defp transmit(event) do
    config = Appsignal.Config.config()
    endpoint = "#{config[:logging_endpoint]}/heartbeats/json"

    case @transmitter.transmit(endpoint, event, config) do
      {:ok, 200, _, _} ->
        nil

      {:ok, status_code, _, _} ->
        Appsignal.IntegrationLogger.warn(
          "Failed to transmit heartbeat: status code was #{status_code}"
        )

      {:error, reason} ->
        Appsignal.IntegrationLogger.warn("Failed to transmit heartbeat: #{reason}")
    end

    :ok
  end
end

defmodule Appsignal.Heartbeat.Event do
  alias __MODULE__
  alias Appsignal.Heartbeat

  @derive Jason.Encoder

  @type kind :: :start | :finish
  @type t :: %Event{name: String.t(), id: String.t(), kind: kind, timestamp: integer}

  defstruct [:name, :id, :kind, :timestamp]

  @spec new(Heartbeat.t(), kind) :: t
  def new(%Heartbeat{name: name, id: id}, kind) do
    %Event{
      name: name,
      id: id,
      kind: kind,
      timestamp: System.system_time(:second)
    }
  end
end
