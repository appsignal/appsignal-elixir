defmodule Appsignal.Probes.ErlangProbeTest do
  alias Appsignal.{FakeAppsignal, Probes.ErlangProbe}
  import AppsignalTest.Utils
  use ExUnit.Case

  setup do
    # Ensure the default probe is unregistered, that way we only record metrics
    # from this test
    Appsignal.Probes.unregister(:erlang)

    [fake_appsignal: start_supervised!(FakeAppsignal)]
  end

  describe "call/0" do
    setup do
      ErlangProbe.call()
    end

    test "gathers IO metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{
                 key: "erlang_io",
                 tags: %{type: "output", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_io",
                 tags: %{type: "input", hostname: "Bobs-MBP.example.com"},
                 value: _
               }
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_io")
    end

    test "gathers scheduler metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{
                 key: "erlang_schedulers",
                 tags: %{type: "online", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_schedulers",
                 tags: %{type: "total", hostname: "Bobs-MBP.example.com"},
                 value: _
               }
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_schedulers")
    end

    test "gathers process metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{
                 key: "erlang_processes",
                 tags: %{type: "count", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_processes",
                 tags: %{type: "limit", hostname: "Bobs-MBP.example.com"},
                 value: _
               }
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_processes")
    end

    test "gathers memory metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{
                 key: "erlang_memory",
                 tags: %{type: "ets", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "code", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "binary", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "atom_used", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "atom", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "system", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "processes_used", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "processes", hostname: "Bobs-MBP.example.com"},
                 value: _
               },
               %{
                 key: "erlang_memory",
                 tags: %{type: "total", hostname: "Bobs-MBP.example.com"},
                 value: _
               }
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_memory")
    end

    test "gathers run queue lengths", %{fake_appsignal: fake_appsignal} do
      assert [
               %{
                 key: "total_run_queue_lengths",
                 tags: %{type: "io"},
                 value: _
               },
               %{
                 key: "total_run_queue_lengths",
                 tags: %{type: "cpu"},
                 value: _
               },
               %{
                 key: "total_run_queue_lengths",
                 tags: %{type: "total"},
                 value: _
               }
             ] = FakeAppsignal.get_gauges(fake_appsignal, "total_run_queue_lengths")
    end
  end

  describe "call/0, with a configured hostname" do
    test "adds the configured hostname as a tag", %{fake_appsignal: fake_appsignal} do
      with_config(%{hostname: "Alices-MBP.example.com"}, &ErlangProbe.call/0)

      assert [%{tags: %{hostname: "Alices-MBP.example.com"}} | _] =
               FakeAppsignal.get_gauges(fake_appsignal, "erlang_io")
    end
  end
end
