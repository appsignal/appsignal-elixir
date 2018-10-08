defmodule Appsignal.ErrorHandler.NormalizeReasonTest do
  use ExUnit.Case

  alias Appsignal.ErrorHandler

  @reason_raw "{:exit, {:timeout, {Task, :await, [%Task{owner: #PID<0.178.0>, pid: #PID<0.179.0>, ref: #Reference<0.0.4.753>}, 1]}}}"
  @reason_norm "{:exit, {:timeout, {Task, :await, [%Task{owner: #PID<...>, pid: #PID<...>, ref: #Reference<...>}, 1]}}}"
  test "Remove pid / ref strings from reason" do
    assert @reason_norm == ErrorHandler.normalize_reason(@reason_raw)
  end
end
