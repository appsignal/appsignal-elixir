defmodule Appsignal.Probes.ErlangProbeTest do
  use ExUnit.Case

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
      assert FakeAppsignal.get(fake_appsignal, "erlang_io")
    end

    test "gathers scheduler metrics", %{fake_appsignal: fake_appsignal} do
      assert FakeAppsignal.get(fake_appsignal, "erlang_schedulers")
    end

    test "gathers process metrics", %{fake_appsignal: fake_appsignal} do
      assert FakeAppsignal.get(fake_appsignal, "erlang_processes")
    end

    test "gathers memory metrics", %{fake_appsignal: fake_appsignal} do
      assert FakeAppsignal.get(fake_appsignal, "erlang_memory")
    end
  end
end
