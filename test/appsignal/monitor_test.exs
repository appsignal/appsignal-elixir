defmodule Appsignal.MonitorTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Monitor, Span, Test, Tracer}

  setup do
    Test.Nif.start_link()
    :ok
  end

  test "is started by the main supervisor" do
    assert is_pid(monitor_pid())
  end

  test "monitors a process" do
    Monitor.add()

    until(fn ->
      assert Process.info(monitor_pid(), :monitors) == {:monitors, [{:process, self()}]}
    end)
  end

  test "does not monitor a process more than once" do
    Monitor.add()
    Monitor.add()

    until(fn ->
      assert Process.info(monitor_pid(), :monitors) == {:monitors, [{:process, self()}]}
    end)
  end

  test "removes entries from the registry when their processes exit" do
    pid =
      spawn(fn ->
        :ets.insert(:"$appsignal_registry", {self(), "span"})
        Monitor.add()
      end)

    until(fn ->
      assert lookup(pid) == [{pid, "span"}]
    end)

    until(fn ->
      assert lookup(pid) == []
    end)
  end

  defp lookup(pid) do
    :ets.lookup(:"$appsignal_registry", pid)
  end

  defp monitor_pid do
    Process.whereis(Monitor)
  end
end
