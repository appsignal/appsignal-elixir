defmodule Appsignal.CheckInTest do
  use ExUnit.Case
  alias Appsignal.CheckIn
  alias Appsignal.CheckIn.Cron
  alias Appsignal.CheckIn.Cron.Event
  alias Appsignal.FakeScheduler

  setup do
    start_supervised!(FakeScheduler)
    :ok
  end

  describe "start/1" do
    test "transmits a start event for the cron check-in" do
      cron = Cron.new("cron-checkin-name")
      Cron.start(cron)

      assert [
               %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end
  end

  describe "finish/1" do
    test "transmits a finish event for the cron check-in" do
      cron = Cron.new("cron-checkin-name")
      Cron.finish(cron)

      assert [
               %Event{identifier: "cron-checkin-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end
  end

  describe "cron/2" do
    test "transmits a start and finish event for the cron check-in" do
      output = CheckIn.cron("cron-checkin-name", fn -> "output" end)

      assert [
               %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron},
               %Event{identifier: "cron-checkin-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()

      assert "output" == output
    end

    test "does not transmit a finish event when the function throws an error" do
      assert_raise RuntimeError, fn ->
        CheckIn.cron("cron-checkin-name", fn -> raise "error" end)
      end

      assert [
               %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end
  end

  describe "cron/1" do
    test "transmits a finish event for the cron check-in" do
      CheckIn.cron("cron-checkin-name")

      assert [
               %Event{identifier: "cron-checkin-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end
  end

  describe "deprecated heartbeat functions" do
    test "forwards heartbeat/1 to CheckIn.cron/1" do
      Appsignal.heartbeat("heartbeat-name")

      assert [
               %Event{identifier: "heartbeat-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end

    test "forwards heartbeat/2 to CheckIn.cron/2" do
      output = Appsignal.heartbeat("heartbeat-name", fn -> "output" end)

      assert [
               %Event{identifier: "heartbeat-name", kind: :start, check_in_type: :cron},
               %Event{identifier: "heartbeat-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()

      assert "output" == output
    end

    test "forwards new/1, start/1 and finish/1 to the CheckIn.Cron module" do
      heartbeat = Appsignal.Heartbeat.new("heartbeat-name")
      Appsignal.Heartbeat.start(heartbeat)
      Appsignal.Heartbeat.finish(heartbeat)

      assert [
               %Event{identifier: "heartbeat-name", kind: :start, check_in_type: :cron},
               %Event{identifier: "heartbeat-name", kind: :finish, check_in_type: :cron}
             ] = FakeScheduler.scheduled()
    end
  end
end
