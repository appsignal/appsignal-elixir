defmodule Appsignal.HeartbeatTest do
  use ExUnit.Case
  alias Appsignal.FakeTransmitter
  alias Appsignal.Heartbeat
  alias Appsignal.Heartbeat.Event
  import AppsignalTest.Utils, only: [with_config: 2]

  setup do
    start_supervised!(FakeTransmitter)
    :ok
  end

  describe "start/1 and finish/1, when AppSignal is not active" do
    test "it does not transmit any events" do
      heartbeat = Heartbeat.new("heartbeat-name")

      with_config(%{active: false}, fn ->
        Heartbeat.start(heartbeat)
        Heartbeat.finish(heartbeat)
      end)

      assert [] = FakeTransmitter.transmitted_payloads()
    end
  end

  describe "start/1" do
    test "transmits a start event for the heartbeat" do
      heartbeat = Heartbeat.new("heartbeat-name")
      Heartbeat.start(heartbeat)

      assert [
               %Event{name: "heartbeat-name", kind: :start}
             ] = FakeTransmitter.transmitted_payloads()
    end
  end

  describe "finish/1" do
    test "transmits a finish event for the heartbeat" do
      heartbeat = Heartbeat.new("heartbeat-name")
      Heartbeat.finish(heartbeat)

      assert [
               %Event{name: "heartbeat-name", kind: :finish}
             ] = FakeTransmitter.transmitted_payloads()
    end
  end

  describe "heartbeat/2" do
    test "transmits a start and finish event for the heartbeat" do
      output = Heartbeat.heartbeat("heartbeat-name", fn -> "output" end)

      assert [
               %Event{name: "heartbeat-name", kind: :start},
               %Event{name: "heartbeat-name", kind: :finish}
             ] = FakeTransmitter.transmitted_payloads()

      assert "output" == output
    end

    test "does not transmit a finish event when the function throws an error" do
      assert_raise RuntimeError, fn ->
        Heartbeat.heartbeat("heartbeat-name", fn -> raise "error" end)
      end

      assert [
               %Event{name: "heartbeat-name", kind: :start}
             ] = FakeTransmitter.transmitted_payloads()
    end
  end

  describe "heartbeat/1" do
    test "transmits a finish event for the heartbeat" do
      Heartbeat.heartbeat("heartbeat-name")

      assert [
               %Event{name: "heartbeat-name", kind: :finish}
             ] = FakeTransmitter.transmitted_payloads()
    end
  end
end
