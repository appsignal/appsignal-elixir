defmodule Appsignal.CheckInSchedulerTest do
  use ExUnit.Case
  alias Appsignal.CheckIn.Cron
  alias Appsignal.CheckIn.Event
  alias Appsignal.CheckIn.Scheduler
  alias Appsignal.FakeDebounce
  alias Appsignal.FakeIntegrationLogger
  alias Appsignal.FakeScheduler
  alias Appsignal.FakeTransmitter
  import AppsignalTest.Utils, only: [with_config: 2, until: 1, until_all_messages_processed: 1]

  def scheduler_events do
    # The events are stored in reverse order.
    Enum.reverse(:sys.get_state(Scheduler)[:events])
  end

  setup do
    # Start the fake scheduler in proxy mode, so that calls to
    # the check-in helpers are forwarded to the real scheduler.
    start_supervised!({FakeScheduler, [:proxy]})
    start_supervised!(FakeIntegrationLogger)
    start_supervised!(FakeTransmitter)
    start_supervised!(FakeDebounce)
    start_supervised!(FakeSystem)

    on_exit(fn ->
      # Restart the check-in scheduler in between tests to clear
      # the stored events and scheduled transmissions.
      Supervisor.terminate_child(Appsignal.Supervisor, Scheduler)
      Supervisor.restart_child(Appsignal.Supervisor, Scheduler)
    end)

    :ok
  end

  describe "start/1 and finish/1, when AppSignal is not active" do
    test "it does not transmit any events" do
      cron = Cron.new("cron-checkin-name")

      with_config(%{active: false}, fn ->
        Cron.start(cron)
        Cron.finish(cron)

        until_all_messages_processed(Scheduler)
      end)

      assert [] = scheduler_events()

      assert FakeIntegrationLogger.logged?(
               :debug,
               &String.starts_with?(
                 &1,
                 "AppSignal not active, not scheduling cron check-in `cron-checkin-name` start event"
               )
             )

      assert FakeIntegrationLogger.logged?(
               :debug,
               &String.starts_with?(
                 &1,
                 "AppSignal not active, not scheduling cron check-in `cron-checkin-name` finish event"
               )
             )
    end
  end

  describe "schedule/1" do
    test "it stores a cron check-in event to be transmitted" do
      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      until_all_messages_processed(Scheduler)

      assert [
               %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
             ] = scheduler_events()

      assert FakeIntegrationLogger.logged?(
               :trace,
               &String.starts_with?(
                 &1,
                 "Scheduling cron check-in `cron-checkin-name` start event"
               )
             )
    end

    test "it does not store redundant events" do
      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)
      Cron.start(cron)

      until_all_messages_processed(Scheduler)

      assert [
               %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
             ] = scheduler_events()

      assert FakeIntegrationLogger.logged?(
               :trace,
               &String.starts_with?(
                 &1,
                 "Scheduling cron check-in `cron-checkin-name` start event"
               )
             )

      assert FakeIntegrationLogger.logged?(
               :debug,
               &String.starts_with?(
                 &1,
                 "Replacing previously scheduled cron check-in `cron-checkin-name` start event"
               )
             )
    end

    test "it transmits the stored event" do
      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      assert [] = FakeTransmitter.transmitted()
      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      assert [
               {[
                  %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
                ], :ndjson}
             ] = FakeTransmitter.transmitted_payloads()

      assert FakeIntegrationLogger.logged?(
               :trace,
               &String.starts_with?(
                 &1,
                 "Transmitted cron check-in `cron-checkin-name` start event"
               )
             )
    end

    test "it transmits many stored events in a single request" do
      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)
      Cron.finish(cron)

      assert [] = FakeTransmitter.transmitted()
      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      assert [
               {[
                  %Event{
                    identifier: "cron-checkin-name",
                    kind: :start,
                    check_in_type: :cron
                  },
                  %Event{
                    identifier: "cron-checkin-name",
                    kind: :finish,
                    check_in_type: :cron
                  }
                ], :ndjson}
             ] = FakeTransmitter.transmitted_payloads()

      until(fn ->
        assert FakeIntegrationLogger.logged?(:trace, "Transmitted 2 check-in events")
      end)
    end

    test "it logs an error when it receives a non-2xx response" do
      FakeTransmitter.set_response({:ok, 500, :fake, :fake})

      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      assert [] = FakeTransmitter.transmitted()
      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      until(fn ->
        assert FakeIntegrationLogger.logged?(
                 :error,
                 &(String.starts_with?(
                     &1,
                     "Failed to transmit cron check-in `cron-checkin-name` start event"
                   ) &&
                     String.ends_with?(&1, ": status code was 500"))
               )
      end)
    end

    test "it logs an error when the request errors" do
      FakeTransmitter.set_response({:error, "fake error"})

      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      assert [] = FakeTransmitter.transmitted()
      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      until(fn ->
        assert FakeIntegrationLogger.logged?(
                 :error,
                 &(String.starts_with?(
                     &1,
                     "Failed to transmit cron check-in `cron-checkin-name` start event"
                   ) &&
                     String.ends_with?(&1, ": fake error"))
               )
      end)
    end

    test "it transmits the stored events when it receives a shutdown signal" do
      # Set a really long debounce time to ensure that the transmission that
      # is taking place is the one triggered by the shutdown signal.
      # The `until/1` call below will time out waiting for this debounce.
      FakeDebounce.set_debounce(10_000)

      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      until_all_messages_processed(Scheduler)

      GenServer.stop(Scheduler)

      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      assert [
               {[
                  %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
                ], :ndjson}
             ] = FakeTransmitter.transmitted_payloads()

      assert FakeIntegrationLogger.logged?(
               :trace,
               &String.starts_with?(
                 &1,
                 "Transmitted cron check-in `cron-checkin-name` start event"
               )
             )
    end

    test "it does not transmit the events twice when it receives a shutdown signal during a transmission" do
      # Cause the transmission to raise an exception, triggering the process
      # to shut down, and `terminate/2` to be called, without the current
      # callback in the process updating the state.
      FakeTransmitter.set_response(fn -> raise "something went wrong" end)

      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      # Wait for the process to attempt to transmit, crash, and call
      # `terminate/2` to shut itself down.
      current_pid = Process.whereis(Scheduler)
      until(fn -> assert !Process.alive?(current_pid) end)

      assert [
               {[
                  %Event{identifier: "cron-checkin-name", kind: :start, check_in_type: :cron}
                ], :ndjson}
             ] = FakeTransmitter.transmitted_payloads()
    end

    test "it uses the last transmission time to debounce the next scheduled transmission" do
      cron = Cron.new("cron-checkin-name")

      Cron.start(cron)

      assert [] = FakeTransmitter.transmitted()
      until(fn -> assert [] != FakeTransmitter.transmitted() end)

      assert FakeDebounce.last_transmission_milliseconds() == nil

      Cron.start(cron)

      until_all_messages_processed(Scheduler)

      assert FakeDebounce.last_transmission_milliseconds() == FakeSystem.system_time(:millisecond)
    end
  end

  describe "milliseconds_until_next_transmission/1" do
    test "returns a short debounce period when no last transmission is given" do
      assert 100 == Scheduler.Debounce.milliseconds_until_next_transmission(nil)
    end

    test "returns a short debounce period when the last transmission was a long time ago" do
      epoch_milliseconds = 0
      assert 100 == Scheduler.Debounce.milliseconds_until_next_transmission(epoch_milliseconds)
    end

    test "returns a long debounce period when the last transmission was now" do
      current_milliseconds = FakeSystem.system_time(:millisecond)

      assert 10000 ==
               Scheduler.Debounce.milliseconds_until_next_transmission(current_milliseconds)
    end

    test "subtracts the time since the last transmission from the long debounce" do
      current_milliseconds = FakeSystem.system_time(:millisecond)
      last_transmission_milliseconds = current_milliseconds - 1000

      assert 9000 ==
               Scheduler.Debounce.milliseconds_until_next_transmission(
                 last_transmission_milliseconds
               )
    end
  end
end
