defmodule Appsignal.Utils.ArgumentCleanerTest do
  alias Appsignal.Utils.{ArgumentCleaner, Type}
  use ExUnit.Case

  test "sensitive types are converted to type structs" do
    assert ArgumentCleaner.clean(:foo) == %Type{type: "atom"}
    assert ArgumentCleaner.clean("bar") == %Type{type: "binary"}
    assert ArgumentCleaner.clean(<<1::1>>) == %Type{type: "bitstring"}
    assert ArgumentCleaner.clean(fn -> nil end) == %Type{type: "function"}
  end

  test "simple types are kept as-is" do
    # is_boolean
    assert ArgumentCleaner.clean(true) == true
    assert ArgumentCleaner.clean(false) == false
    # is_integer
    assert ArgumentCleaner.clean(1) == 1
    # is_float
    assert ArgumentCleaner.clean(1.2) == 1.2
    # is_pid
    pid = :erlang.list_to_pid('<0.0.0>')
    assert ArgumentCleaner.clean(pid) == pid
    # is_port
    port = Port.open({:spawn, "true"}, [])
    assert ArgumentCleaner.clean(port) == port
    # is_reference
    reference = make_ref()
    assert ArgumentCleaner.clean(reference) == reference
  end

  test "values inside composite types are converted to type structs" do
    assert ArgumentCleaner.clean({1, :foo}) == %Type{type: "{integer, atom}"}

    assert ArgumentCleaner.clean([:erlang.list_to_pid('<0.0.0>'), "bar"]) ==
             %Type{type: "[pid, binary]"}
  end

  test "map keys are preserved" do
    assert ArgumentCleaner.clean(%{foo: 1}) == "%{:foo => 1}"
    assert ArgumentCleaner.clean(%{foo: "bar"}) == "%{:foo => binary}"
    assert ArgumentCleaner.clean(%NonEmptyStruct{foo: "bar"}) == "%NonEmptyStruct{:foo => binary}"

    assert ArgumentCleaner.clean(%{foo: :erlang.list_to_pid('<0.0.0>')}) ==
             "%{:foo => #PID<0.0.0>}"
  end
end
