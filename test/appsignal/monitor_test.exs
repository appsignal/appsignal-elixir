defmodule Appsignal.MonitorTest do
  use ExUnit.Case
  alias Appsignal.Monitor

  test "is started by the main supervisor" do
    assert Monitor
           |> Process.whereis()
           |> is_pid()
  end
end
