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
    assert Type.of(:foo) == "atom"
  end

  test "booleans" do
    assert Type.of(true) == "boolean"
    assert Type.of(false) == "boolean"
  end

  test "nils" do
    assert Type.of(nil) == "nil"
  end

  test "binary" do
    assert Type.of("bar") == "binary"
  end

  test "bitstring" do
    assert Type.of(<<1::1>>) == "bitstring"
  end

  test "function" do
    assert Type.of(fn() -> end) == "function"
  end

  test "float" do
    assert Type.of(1.2) == "float"
  end

  test "integer" do
    assert Type.of(1) == "integer"
  end

  test "pid" do
    assert '<0.0.0>'
           |> :erlang.list_to_pid()
           |> Type.of() == "pid"
  end

  test "port" do
    assert Type.of(Port.open({:spawn, "echo foo"}, [])) == "port"
  end

  test "reference" do
    assert Type.of(make_ref()) == "reference"
  end

  test "empty tuple" do
    assert Type.of({}) == "{}"
  end

  test "non-empty tuple" do
    assert Type.of({:foo, "bar"}) == "{atom, binary}"
  end

  test "empty list" do
    assert Type.of([]) == "[]"
  end

  test "non-empty list" do
    assert Type.of([:foo]) == "[atom]"
  end

  test "keyword list" do
    assert Type.of([foo: "bar"]) == "[{atom, binary}]"
  end

  test "empty map" do
    assert Type.of(%{}) == "%{}"
  end

  test "non-empty map" do
    assert Type.of(%{foo: "bar"}) == "%{atom => binary}"
  end

  test "empty struct" do
    assert Type.of(%EmptyStruct{}) == "%EmptyStruct{}"
  end

  test "non-empty struct" do
    assert Type.of(%NonEmptyStruct{foo: 1}) == "%NonEmptyStruct{atom => integer}"
  end
end
