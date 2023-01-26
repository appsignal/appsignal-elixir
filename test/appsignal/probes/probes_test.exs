defmodule Appsignal.Probes.ProbesTest do
  alias Appsignal.Probes
  alias FakeProbe
  import AppsignalTest.Utils
  use ExUnit.Case

  describe "register/2" do
    test "registers a probe when given a function as probe" do
      assert :ok == Probes.register(:some_probe, fn -> nil end)
    end

    test "returns an error tuple when probe is not a function" do
      assert {:error, _} = Probes.register(:some_probe, :some_value)
    end
  end

  describe "integration test for probing" do
    setup do
      [fake_probe: start_supervised!(FakeProbe)]
    end

    test "once a probe is registered, it is called by the probes system", %{
      fake_probe: fake_probe
    } do
      Probes.register(:test_probe, &FakeProbe.call/0)

      refute FakeProbe.get(fake_probe, :probe_called)

      until(fn ->
        assert FakeProbe.get(fake_probe, :probe_called)
      end)

      Probes.unregister(:test_probe)
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

    @tag :skip
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
