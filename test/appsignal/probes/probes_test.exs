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
      fake_probe = start_supervised!(FakeFunctionProbe)
      :ok = Probes.register(:test_probe, FakeFunctionProbe.call(fake_probe))

      on_exit(fn ->
        :ok = Probes.unregister(:test_probe)
      end)

      [fake_probe: fake_probe]
    end

    test "once a probe is registered, it is called by the probes system", %{
      fake_probe: fake_probe
    } do
      refute FakeFunctionProbe.called?(fake_probe)

      until(fn ->
        assert FakeFunctionProbe.called?(fake_probe)
      end)
    end

    test "when a probe is unregistered, it is no longer called by the probes system", %{
      fake_probe: fake_probe
    } do
      until(fn ->
        assert FakeFunctionProbe.called?(fake_probe)
      end)

      assert :ok == Probes.unregister(:test_probe)
      FakeFunctionProbe.clear(fake_probe)

      repeatedly(fn ->
        refute FakeFunctionProbe.called?(fake_probe)
      end)
    end

    test "when a probe with the same name is registered, the existing one is terminated", %{
      fake_probe: fake_probe
    } do
      until(fn ->
        assert FakeFunctionProbe.called?(fake_probe)
      end)

      other_fake_probe = start_supervised!(FakeFunctionProbe, %{id: "other_fake_probe"})

      assert :ok == Probes.register(:test_probe, FakeFunctionProbe.call(other_fake_probe))

      until(fn ->
        assert FakeFunctionProbe.called?(other_fake_probe)
      end)

      FakeFunctionProbe.clear(fake_probe)

      repeatedly(fn ->
        refute FakeFunctionProbe.called?(fake_probe)
      end)
    end

    test "a probe does not get called by the probes system if it's disabled", %{
      fake_probe: fake_probe
    } do
      AppsignalTest.Utils.with_config(%{enable_minutely_probes: false}, fn ->
        repeatedly(fn ->
          refute FakeFunctionProbe.called?(fake_probe)
        end)
      end)
    end
  end

  describe "integration test for failing function probes" do
    setup do
      fake_probe = start_supervised!(FakeFunctionProbe)
      :ok = Probes.register(:test_probe, FakeFunctionProbe.fail(fake_probe))

      on_exit(fn ->
        :ok = Probes.unregister(:test_probe)
      end)

      [fake_probe: fake_probe]
    end

    test "handles non-exception errors", %{fake_probe: fake_probe} do
      until(fn ->
        assert FakeFunctionProbe.called?(fake_probe)
      end)

      assert :ok == Probes.unregister(:test_probe)

      FakeFunctionProbe.clear(fake_probe)

      repeatedly(fn ->
        refute FakeFunctionProbe.called?(fake_probe)
      end)
    end
  end
end
