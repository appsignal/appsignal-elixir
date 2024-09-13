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
