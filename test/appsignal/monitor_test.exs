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

  test "removes entries from the registry when their processes exit" do
    pid =
      spawn(fn ->
        Tracer.create_span("root")
        Monitor.add()
        :timer.sleep(2)
      end)

    until(fn ->
      assert %Span{} = Tracer.current_span(pid)
    end)

    until(fn ->
      assert Tracer.current_span(pid) == nil
    end)
  end

  defp monitor_pid do
    Process.whereis(Monitor)
  end
end
