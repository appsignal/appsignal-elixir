defmodule NonEmptyStruct do
  defstruct [:foo]
end

defmodule Appsignal.Utils.ArgumentCleanerTest do
  alias Appsignal.Utils.{ArgumentCleaner, Type}
  use ExUnit.Case

  test "cleaned types" do
    assert ArgumentCleaner.clean(:foo) == %Type{type: "atom"}
    assert ArgumentCleaner.clean("bar") == %Type{type: "binary"}
    assert ArgumentCleaner.clean(<<1::1>>) == %Type{type: "bitstring"}
    assert ArgumentCleaner.clean(fn -> nil end) == %Type{type: "function"}
  end

  test "untouched types" do
    assert ArgumentCleaner.clean(true) == true
    assert ArgumentCleaner.clean(false) == false
    assert ArgumentCleaner.clean(1) == 1
    assert ArgumentCleaner.clean(1.2) == 1.2
    pid = :erlang.list_to_pid('<0.0.0>')
    assert ArgumentCleaner.clean(pid) == pid
    port = Port.open({:spawn, "echo foo"}, [])
    assert ArgumentCleaner.clean(port) == port
    reference = make_ref()
    assert ArgumentCleaner.clean(reference) == reference
  end

  test "map" do
    assert ArgumentCleaner.clean(%{foo: 1}) == "%{:foo => 1}"
    assert ArgumentCleaner.clean(%{foo: "bar"}) == "%{:foo => binary}"
    assert ArgumentCleaner.clean(%NonEmptyStruct{foo: "bar"}) == "%NonEmptyStruct{:foo => binary}"
  end
end
