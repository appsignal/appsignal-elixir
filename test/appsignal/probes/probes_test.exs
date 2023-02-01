defmodule Appsignal.Probes.ProbesTest do
  alias Appsignal.Probes
  alias FakeProbe
  import AppsignalTest.Utils
  use ExUnit.Case

  setup do
    on_exit(fn ->
      Probes.unregister(:test_probe)
    end)

    [
      fake_probe: start_supervised!(FakeProbe),
      fun: &FakeProbe.call/0
    ]
  end

  describe "with a registered probe" do
    setup %{fun: fun} do
      :ok = Probes.register(:test_probe, fun)
      [fun: fun]
    end

    test "registers a probe", %{fun: fun} do
      assert Probes.probes()[:test_probe] == fun
    end

    test "calls the probe", %{fake_probe: fake_probe} do
      until(fn -> assert FakeProbe.get(fake_probe, :probe_called) end)
    end
  end

  describe "with a non-function probe" do
    setup do
      {:error, "Probe is not a function"} = Probes.register(:test_probe, :error)
      :ok
    end

    test "does not register a probe" do
      refute Map.has_key?(Probes.probes(), :test_probe)
    end
  end

  describe "with an unregistered probe" do
    setup %{fun: fun} do
      :ok = Probes.register(:test_probe, fun)
      :ok = Probes.unregister(:test_probe)
    end

    test "unregisters a probe" do
      refute Map.has_key?(Probes.probes(), :test_probe)
    end
  end

  describe "integration test for probing" do
    setup do
      [fake_probe: start_supervised!(FakeProbe)]
    end

    test "when a probe is registered with the name of a previous probe, it is overridden", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, &FakeProbe.call/0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
      end)

      Probes.register(:test_probe, fn -> nil end)
      FakeProbe.clear()

      repeatedly(fn ->
        refute FakeProbe.get(fake_probe, :probe_called)
      end)

      Probes.register(:test_probe, &FakeProbe.call/0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
    end

    test "a probe does not get called by the probes system if it's disabled", %{
      fake_probe: fake_probe
    } do
      AppsignalTest.Utils.with_config(%{enable_minutely_probes: false}, fn ->
        Probes.register(:test_probe, &FakeProbe.call/0)

        repeatedly(fn ->
          refute FakeProbe.get(fake_probe, :probe_called)
        end)

        Probes.unregister(:test_probe)
      end)
    end

    test "a probe receives the resulting state from its previous call", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, &FakeProbe.stateful/1, 0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
        assert FakeProbe.get(fake_probe, :probe_state) >= 3
      end)

      Probes.unregister(:test_probe)
    end

    test "when a probe is overridden, its state is reset", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, &FakeProbe.stateful/1, 0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
        assert FakeProbe.get(fake_probe, :probe_state) >= 3
      end)

      Probes.register(:test_probe, &FakeProbe.stateful/1, 0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
        assert FakeProbe.get(fake_probe, :probe_state) < 3
      end)

      Probes.unregister(:test_probe)
    end

    test "handles non-exception errors", %{fake_probe: fake_probe} do
      Probes.register(:test_probe, &FakeProbe.fail/0)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
    end
  end
end
