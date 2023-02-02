defmodule Appsignal.Probes.ErlangProbeTest do
  alias Appsignal.{FakeAppsignal, Probes, Probes.ErlangProbe}
  import AppsignalTest.Utils
  use ExUnit.Case

  setup do
    [fake_appsignal: start_supervised!(FakeAppsignal)]
  end

  test "is added to the probes automatically" do
    until(fn ->
      assert Probes.probes()[:erlang] == (&ErlangProbe.call/1)
    end)
  end

  describe "metrics/2" do
    setup do
      [metrics: ErlangProbe.metrics(nil, nil)]
    end

    test "returns io metrics", %{metrics: metrics} do
      assert [{"erlang_io", input, %{type: "input"}}, {"erlang_io", output, %{type: "output"}}] =
               Enum.filter(metrics, fn {key, _, _} -> key == "erlang_io" end)

      assert is_number(input)
      assert is_number(output)
    end

    test "returns scheduler metrics", %{metrics: metrics} do
      assert [
               {"erlang_schedulers", total, %{type: "total"}},
               {"erlang_schedulers", online, %{type: "online"}}
             ] = Enum.filter(metrics, fn {key, _, _} -> key == "erlang_schedulers" end)

      assert is_number(total)
      assert is_number(online)
    end

    test "returns process metrics", %{metrics: metrics} do
      assert [
               {"erlang_processes", limit, %{type: "limit"}},
               {"erlang_processes", count, %{type: "count"}}
             ] = Enum.filter(metrics, fn {key, _, _} -> key == "erlang_processes" end)

      assert is_number(limit)
      assert is_number(count)
    end

    test "returns memory metrics", %{metrics: metrics} do
      assert [
               {"erlang_memory", total, %{type: "total"}},
               {"erlang_memory", processes, %{type: "processes"}},
               {"erlang_memory", processes_used, %{type: "processes_used"}},
               {"erlang_memory", system, %{type: "system"}},
               {"erlang_memory", atom, %{type: "atom"}},
               {"erlang_memory", atom_used, %{type: "atom_used"}},
               {"erlang_memory", binary, %{type: "binary"}},
               {"erlang_memory", code, %{type: "code"}},
               {"erlang_memory", ets, %{type: "ets"}}
             ] = Enum.filter(metrics, fn {key, _, _} -> key == "erlang_memory" end)

      assert is_number(total)
      assert is_number(processes)
      assert is_number(processes_used)
      assert is_number(system)
      assert is_number(atom)
      assert is_number(atom_used)
      assert is_number(binary)
      assert is_number(code)
      assert is_number(ets)
    end

    test "returns atom metrics", %{metrics: metrics} do
      assert [
               {"erlang_atoms", limit, %{type: "limit"}},
               {"erlang_atoms", count, %{type: "count"}}
             ] = Enum.filter(metrics, fn {key, _, _} -> key == "erlang_atoms" end)

      assert is_number(limit)
      assert is_number(count)
    end

    test "returns run queue lengths", %{metrics: metrics} do
      assert [
               {"total_run_queue_lengths", total, %{type: "total"}},
               {"total_run_queue_lengths", cpu, %{type: "cpu"}},
               {"total_run_queue_lengths", io, %{type: "io"}}
             ] = Enum.filter(metrics, fn {key, _, _} -> key == "total_run_queue_lengths" end)

      assert is_number(total)
      assert is_number(cpu)
      assert is_number(io)
    end

    test "does not return scheduler utilization metrics", %{metrics: metrics} do
      assert [] =
               Enum.filter(metrics, fn {key, _, _} -> key == "erlang_scheduler_utilization" end)
    end

    test "sets hostnames for all metrics", %{metrics: metrics} do
      assert Enum.all?(metrics, fn {_, _, tags} ->
               tags[:hostname] == "Bobs-MBP.example.com"
             end)
    end
  end

  describe "metrics/2, when called with two scheduler samples" do
    setup do
      [
        metrics:
          ErlangProbe.metrics(ErlangProbe.sample_schedulers(), ErlangProbe.sample_schedulers())
      ]
    end

    test "returns scheduler utilization metrics", %{metrics: metrics} do
      metrics = Enum.filter(metrics, fn {key, _, _} -> key == "erlang_scheduler_utilization" end)

      assert Enum.any?(metrics)

      Enum.each(metrics, fn {"erlang_scheduler_utilization", value, %{id: id, type: "normal"}} ->
        assert is_number(value)
        assert {_, _} = Integer.parse(id)
      end)
    end
  end
end
