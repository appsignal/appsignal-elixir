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
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "erlang_io")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_io",
                   tags: %{type: "output", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_io",
                   tags: %{type: "input", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )
    end

    test "gathers scheduler metrics", %{fake_appsignal: fake_appsignal} do
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "erlang_schedulers")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_schedulers",
                   tags: %{type: "online", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_schedulers",
                   tags: %{type: "total", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )
    end

    test "gathers process metrics", %{fake_appsignal: fake_appsignal} do
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "erlang_processes")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_processes",
                   tags: %{type: "count", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_processes",
                   tags: %{type: "limit", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )
    end

    test "gathers memory metrics", %{fake_appsignal: fake_appsignal} do
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "erlang_memory")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "ets", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "code", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "binary", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "atom_used", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "atom", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "system", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "processes_used", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "processes", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_memory",
                   tags: %{type: "total", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )
    end

    test "gathers atom metrics", %{fake_appsignal: fake_appsignal} do
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "erlang_atoms")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_atoms",
                   tags: %{type: "count", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "erlang_atoms",
                   tags: %{type: "limit", hostname: "Bobs-MBP.example.com"},
                   value: _
                 },
                 &1
               )
             )
    end

    test "gathers run queue lengths", %{fake_appsignal: fake_appsignal} do
      metrics = FakeAppsignal.get_gauges(fake_appsignal, "total_run_queue_lengths")

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "total_run_queue_lengths",
                   tags: %{type: "io"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "total_run_queue_lengths",
                   tags: %{type: "cpu"},
                   value: _
                 },
                 &1
               )
             )

      assert Enum.any?(
               metrics,
               &match?(
                 %{
                   key: "total_run_queue_lengths",
                   tags: %{type: "total"},
                   value: _
                 },
                 &1
               )
             )
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
