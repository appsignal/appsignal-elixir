defmodule EmptyStruct do
  defstruct []
end

defmodule NonEmptyStruct do
  defstruct [:foo]
end

defmodule Appsignal.Utils.TypeTest do
  use ExUnit.Case
  alias Appsignal.Utils.Type

  test "atom" do
    assert Type.from(:foo).type == "atom"
  end

  test "booleans" do
    assert Type.from(true).type == "boolean"
    assert Type.from(false).type == "boolean"
  end

  test "nils" do
    assert Type.from(nil).type == "nil"
  end

  test "binary" do
    assert Type.from("bar").type == "binary"
  end

  test "bitstring" do
    assert Type.from(<<1::1>>).type == "bitstring"
  end

  test "function" do
    assert Type.from(fn() -> end).type == "function"
  end

  test "float" do
    assert Type.from(1.2).type == "float"
  end

  test "integer" do
    assert Type.from(1).type == "integer"
  end

  test "pid" do
    assert Type.from(:erlang.list_to_pid('<0.0.0>')).type == "pid"
  end

  test "port" do
    assert Type.of(Port.open({:spawn, "echo foo"}, [])) == "port"
  end

  test "reference" do
    assert Type.of(make_ref()) == "reference"
  end

  test "empty tuple" do
    assert Type.from({}).type == "{}"
  end

  test "non-empty tuple" do
    assert Type.from({:foo, "bar"}).type == "{atom, binary}"
  end

  test "empty list" do
    assert Type.from([]).type == "[]"
  end

  test "non-empty list" do
    assert Type.from([:foo]).type == "[atom]"
  end

  test "keyword list" do
    assert Type.from([foo: "bar"]).type == "[{atom, binary}]"
  end

  test "empty map" do
    assert Type.from(%{}).type == "%{}"
  end

  test "non-empty map" do
    assert Type.from(%{foo: "bar"}).type == "%{atom => binary}"
  end

  test "empty struct" do
    assert Type.from(%EmptyStruct{}).type == "%EmptyStruct{}"
  end

  test "non-empty struct" do
    assert Type.from(%NonEmptyStruct{foo: 1}).type == "%NonEmptyStruct{atom => integer}"
  end

  test "inspect" do
    assert inspect(Type.from("string")) == "binary"
  end
end
