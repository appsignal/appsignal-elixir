defmodule Appsignal.Probes.SchedulerTest do
  alias Appsignal.Probes
  import AppsignalTest.Utils
  use ExUnit.Case

  describe "Scheduler" do
    test "calls the probes started in the DynamicSupervisor" do
      {:ok, fake_probe} = DynamicSupervisor.start_child(Probes.DynamicSupervisor, FakeServerProbe)

      refute FakeServerProbe.probed?(fake_probe)

      until(fn ->
        assert FakeServerProbe.probed?(fake_probe)
      end)

      DynamicSupervisor.terminate_child(Probes.DynamicSupervisor, fake_probe)
    end
  end
end
