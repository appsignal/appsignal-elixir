defmodule Appsignal.Probes.ErlangProbeTest do
  use ExUnit.Case, async: false

  alias Appsignal.{FakeAppsignal, Probes.ErlangProbe}

  setup do
    {:ok, fake_appsignal} = FakeAppsignal.start_link()

    [fake_appsignal: fake_appsignal]
  end

  describe "call/0" do
    setup do
      ErlangProbe.call()
    end

    test "gathers IO metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: "erlang_io", tags: %{type: "output"}, value: _},
               %{key: "erlang_io", tags: %{type: "input"}, value: _}
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_io")
    end

    test "gathers scheduler metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: "erlang_schedulers", tags: %{type: "online"}, value: _},
               %{key: "erlang_schedulers", tags: %{type: "total"}, value: _}
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_schedulers")
    end

    test "gathers process metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: "erlang_processes", tags: %{type: "count"}, value: _},
               %{key: "erlang_processes", tags: %{type: "limit"}, value: _}
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_processes")
    end

    test "gathers memory metrics", %{fake_appsignal: fake_appsignal} do
      assert [
               %{key: "erlang_memory", tags: %{type: "ets"}, value: _},
               %{key: "erlang_memory", tags: %{type: "code"}, value: _},
               %{key: "erlang_memory", tags: %{type: "binary"}, value: _},
               %{key: "erlang_memory", tags: %{type: "atom_used"}, value: _},
               %{key: "erlang_memory", tags: %{type: "atom"}, value: _},
               %{key: "erlang_memory", tags: %{type: "system"}, value: _},
               %{key: "erlang_memory", tags: %{type: "processes_used"}, value: _},
               %{key: "erlang_memory", tags: %{type: "processes"}, value: _},
               %{key: "erlang_memory", tags: %{type: "total"}, value: _}
             ] = FakeAppsignal.get_gauges(fake_appsignal, "erlang_memory")
    end
  end
end
