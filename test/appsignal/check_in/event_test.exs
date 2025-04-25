defmodule Appsignal.CheckInEventTest do
  use ExUnit.Case
  alias Appsignal.CheckIn.Cron
  alias Appsignal.CheckIn.Event

  describe "describe/1" do
    test "describes a list of many events" do
      events = [
        Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :start),
        Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :finish),
        Event.heartbeat("heartbeat-checkin-name")
      ]

      assert "3 check-in events" == Event.describe(events)
    end

    test "describes one cron check-in event" do
      event = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "some-digest"}, :start)

      assert "cron check-in `cron-checkin-name` start event (digest some-digest)" ==
               Event.describe([event])
    end

    test "describes one heartbeat check-in event" do
      event = Event.heartbeat("heartbeat-checkin-name")

      assert "heartbeat check-in `heartbeat-checkin-name` event" == Event.describe([event])
    end

    test "describes one unknown check-in event" do
      event = %Event{}

      assert "unknown check-in event" == Event.describe([event])
    end

    test "describs an empty list of events" do
      assert "no check-in events" == Event.describe([])
    end
  end

  describe "redundant?/2" do
    test "returns false if the events are of different types" do
      event1 = Event.heartbeat("checkin-name")
      event2 = Event.heartbeat("checkin-name")

      event2 = Map.put(event2, :check_in_type, :cron)

      assert false == Event.redundant?(event1, event2)
    end

    test "returns false if the events are of unknown type" do
      event1 = %Event{}
      event2 = %Event{}

      assert false == Event.redundant?(event1, event2)
    end

    test "returns false if heartbeat events have different identifiers" do
      event1 = Event.heartbeat("heartbeat-checkin-name")
      event2 = Event.heartbeat("another-heartbeat-checkin-name")

      assert false == Event.redundant?(event1, event2)
    end

    test "returns true if heartbeat events have the same identifier" do
      event1 = Event.heartbeat("heartbeat-checkin-name")
      event2 = Event.heartbeat("heartbeat-checkin-name")

      assert true == Event.redundant?(event1, event2)
    end

    test "returns false if cron events have different identifiers" do
      event1 = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :start)

      event2 =
        Event.cron(%Cron{identifier: "another-cron-checkin-name", digest: "digest"}, :start)

      assert false == Event.redundant?(event1, event2)
    end

    test "returns false if cron events have different kinds" do
      event1 = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :start)
      event2 = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :finish)

      assert false == Event.redundant?(event1, event2)
    end

    test "returns false if cron events have different digests" do
      event1 = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "digest"}, :start)
      event2 = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "other-digest"}, :start)

      assert false == Event.redundant?(event1, event2)
    end

    test "returns true if cron events have the same identifier, kind and digest" do
      cron = %Cron{identifier: "cron-checkin-name"}

      event1 = Event.cron(cron, :start)
      event2 = Event.cron(cron, :start)

      assert true == Event.redundant?(event1, event2)
    end
  end

  describe "deduplicate_cron/1" do
    test "removes redundant pairs of cron events" do
      first_start = Event.cron(%Cron{identifier: "checkin-name", digest: "first"}, :start)
      first_finish = Event.cron(%Cron{identifier: "checkin-name", digest: "first"}, :finish)
      second_start = Event.cron(%Cron{identifier: "checkin-name", digest: "second"}, :start)
      second_finish = Event.cron(%Cron{identifier: "checkin-name", digest: "second"}, :finish)

      events = [first_start, first_finish, second_start, second_finish]

      for perm <- permutations(events) do
        result = Event.deduplicate_cron(perm)

        assert length(result) == 2
        [kept_finish, kept_start] = Enum.sort_by(result, & &1.kind)
        assert kept_start.kind == :start
        assert kept_finish.kind == :finish
        assert kept_start.digest == kept_finish.digest
      end
    end

    test "does not remove pairs with different identifiers" do
      first_start = Event.cron(%Cron{identifier: "checkin-name", digest: "first"}, :start)
      first_finish = Event.cron(%Cron{identifier: "checkin-name", digest: "first"}, :finish)
      second_start = Event.cron(%Cron{identifier: "other-checkin", digest: "second"}, :start)
      second_finish = Event.cron(%Cron{identifier: "other-checkin", digest: "second"}, :finish)

      events = [first_start, first_finish, second_start, second_finish]

      for perm <- permutations(events) do
        result = Event.deduplicate_cron(perm)
        assert MapSet.new(result) == MapSet.new(events)
      end
    end

    test "does not remove unmatched pairs" do
      first_start = Event.cron(%Cron{identifier: "checkin-name", digest: "first"}, :start)
      second_start = Event.cron(%Cron{identifier: "checkin-name", digest: "second"}, :start)
      second_finish = Event.cron(%Cron{identifier: "checkin-name", digest: "second"}, :finish)
      third_finish = Event.cron(%Cron{identifier: "checkin-name", digest: "third"}, :finish)

      events = [first_start, second_start, second_finish, third_finish]

      for perm <- permutations(events) do
        result = Event.deduplicate_cron(perm)
        assert MapSet.new(result) == MapSet.new(events)
      end
    end

    # Helper function to generate all permutations of a list
    defp permutations([]), do: [[]]

    defp permutations(list) do
      for x <- list,
          y <- permutations(list -- [x]),
          do: [x | y]
    end
  end

  describe "impl Jason.Encoder" do
    test "encodes a cron check-in event" do
      event = Event.cron(%Cron{identifier: "cron-checkin-name", digest: "some-digest"}, :start)

      encoded = Jason.encode!(event)

      assert String.contains?(encoded, "\"identifier\":\"cron-checkin-name\"")
      assert String.contains?(encoded, "\"digest\":\"some-digest\"")
      assert String.contains?(encoded, "\"kind\":\"start\"")
      assert String.contains?(encoded, "\"timestamp\":")
      assert String.contains?(encoded, "\"check_in_type\":\"cron\"")

      assert is_map(Jason.decode!(encoded))
    end

    test "encodes a heartbeat check-in event" do
      event = Event.heartbeat("heartbeat-checkin-name")

      encoded = Jason.encode!(event)

      assert String.contains?(encoded, "\"identifier\":\"heartbeat-checkin-name\"")
      assert !String.contains?(encoded, "\"digest\"")
      assert !String.contains?(encoded, "\"kind\"")
      assert String.contains?(encoded, "\"timestamp\":")
      assert String.contains?(encoded, "\"check_in_type\":\"heartbeat\"")

      assert is_map(Jason.decode!(encoded))
    end
  end
end
