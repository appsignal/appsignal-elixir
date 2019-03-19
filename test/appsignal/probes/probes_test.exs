defmodule Appsignal.Probes.ProbesTest do
  use ExUnit.Case, async: false

  alias Appsignal.Probes
  alias FakeProbe

  describe "register/2" do
    test "does register a probe when given a function as probe" do
      assert :ok == Probes.register(:some_probe, fn -> nil end)
    end

    test "returns an error tupple when probe is not a function" do
      assert {:error, _} = Probes.register(:some_probe, :some_value)
    end
  end

  describe "integration test for probing" do
    setup do
      {:ok, fake_probe} = FakeProbe.start_link()
      [fake_probe: fake_probe]
    end

    test "once a probe is registered, it is called by the probes system", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, &FakeProbe.call/0)

      refute FakeProbe.get(fake_probe, :probe_called)

      # Sleep for some time to give the Probe system time to do its work
      :timer.sleep(1000)

      assert FakeProbe.get(fake_probe, :probe_called)

      Probes.unregister(:test_probe)
    end
  end
end
