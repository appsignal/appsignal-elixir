defmodule Appsignal.CheckIn.Event do
  alias __MODULE__
  alias Appsignal.CheckIn.Cron

  @type kind :: :start | :finish
  @type check_in_type :: :cron | :heartbeat
  @type t :: %Event{
          identifier: String.t(),
          digest: String.t() | nil,
          kind: kind | nil,
          timestamp: integer,
          check_in_type: check_in_type
        }

  defstruct [:identifier, :digest, :kind, :timestamp, :check_in_type]

  @spec cron(Cron.t(), kind) :: t
  def cron(%Cron{identifier: identifier, digest: digest}, kind) do
    %Event{
      identifier: identifier,
      digest: digest,
      kind: kind,
      timestamp: System.system_time(:second),
      check_in_type: :cron
    }
  end

  @spec heartbeat(String.t()) :: t
  def heartbeat(identifier) do
    %Event{
      identifier: identifier,
      timestamp: System.system_time(:second),
      check_in_type: :heartbeat
    }
  end

  @spec describe([t]) :: String.t()
  def describe([]) do
    # This shouldn't happen.
    "no check-in events"
  end

  def describe([%Event{check_in_type: :cron} = event]) do
    "cron check-in `#{event.identifier || "unknown"}` " <>
      "#{event.kind || "unknown"} event (digest #{event.digest || "unknown"})"
  end

  def describe([%Event{check_in_type: :heartbeat} = event]) do
    "heartbeat check-in `#{event.identifier || "unknown"}` event"
  end

  def describe([_event]) do
    # This shouldn't happen.
    "unknown check-in event"
  end

  def describe(events) do
    "#{Enum.count(events)} check-in events"
  end

  @spec redundant?(t, t) :: boolean
  def redundant?(
        %Event{check_in_type: :cron} = event,
        %Event{check_in_type: :cron} = new_event
      ) do
    # Consider any existing cron check-in event redundant if it has the
    # same identifier, digest and kind as the one we're adding.
    event.identifier == new_event.identifier &&
      event.kind == new_event.kind &&
      event.digest == new_event.digest
  end

  def redundant?(
        %Event{check_in_type: :heartbeat} = event,
        %Event{check_in_type: :heartbeat} = new_event
      ) do
    # Consider any existing heartbeat check-in event redundant if it has
    # the same identifier as the one we're adding.
    event.identifier == new_event.identifier
  end

  def redundant?(_event, _new_event), do: false
end

defimpl Jason.Encoder, for: Appsignal.CheckIn.Event do
  def encode(%Appsignal.CheckIn.Event{} = event, opts) do
    event
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})
    |> Jason.Encode.map(opts)
  end
end
