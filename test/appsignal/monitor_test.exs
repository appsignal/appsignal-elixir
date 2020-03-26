defmodule Appsignal.MonitorTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Monitor

  test "is started by the main supervisor" do
    assert is_pid(monitor_pid())
  end

  test "monitors a process" do
    Monitor.add()

    until(fn ->
      assert Process.info(monitor_pid(), :monitors) == {:monitors, [{:process, self()}]}
    end)
  end

  defp monitor_pid do
    Process.whereis(Monitor)
  end
end
