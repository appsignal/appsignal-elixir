defmodule Appsignal.Probes.ProbesTest do
  alias Appsignal.Probes
  import AppsignalTest.Utils
  use ExUnit.Case

  describe "register/2" do
    test "registers a probe when given a function as probe" do
      assert :ok == Probes.register(:some_probe, fn -> nil end)
      Probes.unregister(:some_probe)
    end

    test "registers a probe when given a module as probe" do
      assert :ok == Probes.register(:some_probe, FakeServerProbe)
      Probes.unregister(:some_probe)
    end
  end

  describe "integration test for probing" do
    setup do
      [fake_probe: start_supervised!(FakeFunctionProbe)]
    end

    test "once a probe is registered, it is called by the probes system", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, FakeFunctionProbe.call(fake_probe))

      refute FakeFunctionProbe.get(fake_probe, :probe_called)

      until(fn ->
        assert FakeFunctionProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
    end

    test "when a probe is unregistered, it is no longer called by the probes system", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, FakeFunctionProbe.call(fake_probe))

      until(fn ->
        assert FakeFunctionProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
      FakeFunctionProbe.update(fake_probe, :probe_called, false)

      repeatedly(fn ->
        refute FakeFunctionProbe.get(fake_probe, :probe_called)
      end)
    end

    test "when a probe with the same name is registered, the existing one is terminated", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, FakeFunctionProbe.call(fake_probe))

      until(fn ->
        assert FakeFunctionProbe.get(fake_probe, :probe_called)
      end)

      agent = start_supervised!({Agent, fn -> false end})

      function = fn ->
        Agent.update(agent, fn _ -> true end)
      end

      Probes.register(:test_probe, function)
      FakeFunctionProbe.update(fake_probe, :probe_called, false)

      until(fn ->
        assert Agent.get(agent, fn state -> state end)
      end)

      repeatedly(fn ->
        refute FakeFunctionProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
    end

    test "a probe does not get called by the probes system if it's disabled", %{
      fake_probe: fake_probe
    } do
      AppsignalTest.Utils.with_config(%{enable_minutely_probes: false}, fn ->
        Probes.register(:test_probe, FakeFunctionProbe.call(fake_probe))

        repeatedly(fn ->
          refute FakeFunctionProbe.get(fake_probe, :probe_called)
        end)

        Probes.unregister(:test_probe)
      end)
    end

    test "handles non-exception errors", %{fake_probe: fake_probe} do
      Probes.register(:test_probe, FakeFunctionProbe.fail(fake_probe))

      until(fn ->
        assert FakeFunctionProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
    end
  end
end
