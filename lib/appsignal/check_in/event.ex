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

  @doc """
  Removes redundant cron check-in events from the given list of events.
  This is done by removing redundant *pairs* of events -- that is,
  for each identifier, only keep one complete pair of start and finish events.
  """
  @spec deduplicate_cron(list(t)) :: list(t)
  def deduplicate_cron(events) do
    # Group the events by identifier
    {start_digests, finish_digests} =
      Enum.reduce(events, {%{}, %{}}, fn
        %Event{check_in_type: :cron, kind: kind, identifier: id, digest: digest},
        {starts, finishes}
        when kind in [:start, :finish] ->
          case kind do
            :start ->
              {Map.update(starts, id, MapSet.new([digest]), &MapSet.put(&1, digest)), finishes}

            :finish ->
              {starts, Map.update(finishes, id, MapSet.new([digest]), &MapSet.put(&1, digest))}
          end

        _event, acc ->
          acc
      end)

    # Find complete pairs and keep only the latest one
    complete_pairs =
      Enum.reduce(Map.keys(start_digests), %{}, fn id, acc ->
        starts = Map.fetch!(start_digests, id)

        case Map.get(finish_digests, id) do
          nil ->
            acc

          finishes ->
            # Find all complete pairs for this identifier
            complete = MapSet.intersection(starts, finishes)

            if MapSet.size(complete) > 0 do
              # Keep any digest as the one to keep (e.g., the first one)
              keep = Enum.fetch!(complete, 0)
              Map.put(acc, id, {complete, keep})
            else
              acc
            end
        end
      end)

    # Filter events, keeping non-complete pairs and the latest complete pair
    Enum.reject(events, fn
      %Event{check_in_type: :cron, identifier: id, digest: digest, kind: kind}
      when kind in [:start, :finish] ->
        case Map.get(complete_pairs, id) do
          {complete, keep} ->
            # Remove if it's part of a complete pair but not the one to keep
            digest != keep and MapSet.member?(complete, digest)

          _ ->
            false
        end

      _ ->
        false
    end)
  end
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
