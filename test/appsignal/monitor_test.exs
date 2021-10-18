defmodule Appsignal.MonitorTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Monitor, Test}

  setup do
    start_supervised!(Test.Nif)
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

  test "automatically removes pids that don't exist from the monitor list" do
    pid = :erlang.list_to_pid('<0.999.0>')
    GenServer.cast(Appsignal.Monitor, {:monitor, pid})

    until(fn ->
      assert MapSet.size(:sys.get_state(Appsignal.Monitor)) == 0
    end)
  end

  test "syncs the monitors list" do
    Monitor.add()
    :sys.replace_state(Appsignal.Monitor, fn _ -> MapSet.new() end)

    until(fn ->
      assert MapSet.size(:sys.get_state(Appsignal.Monitor)) == 0
    end)

    send(Appsignal.Monitor, :sync)

    until(fn ->
      assert MapSet.member?(:sys.get_state(Appsignal.Monitor), self())
    end)
  end

  defp lookup(pid) do
    :ets.lookup(:"$appsignal_registry", pid)
  end

  defp monitor_pid do
    Process.whereis(Monitor)
  end
end
