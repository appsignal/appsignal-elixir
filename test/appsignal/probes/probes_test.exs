defmodule Appsignal.Probes.ProbesTest do
  alias Appsignal.Probes
  alias FakeProbe
  import AppsignalTest.Utils
  use ExUnit.Case

  setup do
    on_exit(fn ->
      Probes.unregister(:test_probe)
    end)

    [fun: fn state -> state + 1 end]
  end

  describe "with a registered probe" do
    setup %{fun: fun} do
      :ok = Probes.register(:test_probe, fun, 0)
      [fun: fun]
    end

    test "registers a probe", %{fun: fun} do
      assert Probes.probes()[:test_probe] == fun
    end

    test "calls the probe automatically" do
      until(fn -> assert Probes.states()[:test_probe] > 0 end)
    end

    test "increments internal state" do
      run_probes()
      run_probes()

      assert Probes.states()[:test_probe] > 1
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

  describe "with an overridden probe" do
    setup do
      fun = fn -> fn state -> state end end
      :ok = Probes.register(:test_probe, fn state -> state end, 10)
      :ok = Probes.register(:test_probe, fun, 0)
      [fun: fun]
    end

    test "overrides the probe", %{fun: fun} do
      assert Probes.probes()[:test_probe] == fun
      assert Probes.states()[:test_probe] == 0
    end
  end

  describe "with minutely probes disabled" do
    setup %{fun: fun} do
      setup_with_config(%{enable_minutely_probes: false})

      :ok = Probes.register(:test_probe, fun, 0)
    end

    test "does not call the probe" do
      run_probes()

      assert Probes.states()[:test_probe] == 0
    end
  end

  describe "with a failing probe" do
    setup %{fun: fun} do
      :ok = Probes.register(:test_probe, fn -> raise "Probe exception!" end, 0)
      [fun: fun]
    end

    test "calls the probe without crashing the probes" do
      run_probes()
    end
  end
end
