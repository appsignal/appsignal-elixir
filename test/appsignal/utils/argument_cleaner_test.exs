defmodule Appsignal.Utils.ArgumentCleanerTest do
  alias Appsignal.Utils.ArgumentCleaner
  use ExUnit.Case

  test "cleaning atoms keeps them as-is" do
    assert ArgumentCleaner.clean(:foo) == ":foo"
  end

  test "cleaning booleans keeps them as-is" do
    assert ArgumentCleaner.clean(true) == "true"
    assert ArgumentCleaner.clean(false) == "false"
  end

  test "cleaning nil keeps it as-is" do
    assert ArgumentCleaner.clean(nil) == "nil"
  end

  test "cleaning strings omits their contents" do
    assert ArgumentCleaner.clean("foo") == "\"...\""
  end

  test "cleaning bitstrings omits their contents" do
    assert ArgumentCleaner.clean(<<1::1>>) == "<<...>>"
  end

  test "cleaning integers replaces them with their typespec" do
    assert ArgumentCleaner.clean(123) == "integer()"
  end

  test "cleaning floats replaces them with their typespec" do
    assert ArgumentCleaner.clean(1.23) == "float()"
  end

  test "cleaning PIDs omits their value" do
    assert ArgumentCleaner.clean(:erlang.list_to_pid('<0.1.2>')) == "#PID<...>"
  end

  test "cleaning ports omits their value" do
    assert ArgumentCleaner.clean(:erlang.list_to_port('#Port<0.1>')) == "#Port<...>"
  end

  test "cleaning references omits their value" do
    assert ArgumentCleaner.clean(:erlang.list_to_ref('#Ref<0.1.2.3>')) == "#Reference<...>"
  end

  test "cleaning named functions shows their MFA" do
    assert ArgumentCleaner.clean(&Enum.to_list/1) == "&Enum.to_list/1"
  end

  test "cleaning anonymous functions shows their arity" do
    assert ArgumentCleaner.clean(fn -> nil end) == "fn -> ... end"
    assert ArgumentCleaner.clean(fn x -> x end) == "fn _ -> ... end"
    assert ArgumentCleaner.clean(fn x, y -> x + y end) == "fn _, _ -> ... end"
  end

  test "cleaning small tuples shows their cleaned contents" do
    assert ArgumentCleaner.clean({}) == "{}"
    assert ArgumentCleaner.clean({{{}}}) == "{{{}}}"
    assert ArgumentCleaner.clean({:foo, {"bar"}}) == "{:foo, {\"...\"}}"
    assert ArgumentCleaner.clean({:a, :b, :c, :d}) == "{:a, :b, :c, :d}"
  end

  test "cleaning big tuples omits their contents" do
    assert ArgumentCleaner.clean({:a, :b, :c, :d, :e}) == "{...}"
  end

  test "cleaning deeply nested tuples omits their contents" do
    assert ArgumentCleaner.clean({{{:foo}}}) == "{{{...}}}"
    assert ArgumentCleaner.clean({{{{}}}}) == "{{{...}}}"
    assert ArgumentCleaner.clean(%{foo: %{bar: {:baz}}}) == "%{foo: %{bar: {...}}}"
  end

  test "cleaning small maps shows their cleaned contents" do
    assert ArgumentCleaner.clean(%{}) == "%{}"
    assert ArgumentCleaner.clean(%{a: %{b: %{}}}) == "%{a: %{b: %{}}}"

    assert ArgumentCleaner.clean(%{a: :foo, b: %{bar: "foo"}}) == "%{a: :foo, b: %{bar: \"...\"}}"

    assert ArgumentCleaner.clean(%{"a" => :foo, "b" => %{"bar" => "foo"}}) ==
             "%{\"...\" => :foo, \"...\" => %{\"...\" => \"...\"}}"

    assert ArgumentCleaner.clean(%{a: :a, b: :b, c: :c, d: :d}) == "%{a: :a, b: :b, c: :c, d: :d}"
  end

  test "cleaning big maps omits their contents" do
    assert ArgumentCleaner.clean(%{a: :a, b: :b, c: :c, d: :d, e: :e}) == "%{...}"
  end

  test "cleaning deeply nested maps omits their contents" do
    assert ArgumentCleaner.clean(%{a: %{b: %{foo: :bar}}}) == "%{a: %{b: %{...}}}"
    assert ArgumentCleaner.clean(%{a: %{b: %{foo: %{}}}}) == "%{a: %{b: %{...}}}"
    assert ArgumentCleaner.clean({{%{foo: :bar}}}) == "{{%{...}}}"
  end

  test "cleaning structs omits their contents" do
    assert ArgumentCleaner.clean(%EmptyStruct{}) == "%EmptyStruct{}"

    assert ArgumentCleaner.clean(%NonEmptyStruct{foo: :foo}) == "%NonEmptyStruct{...}"
  end

  test "cleaning lists omits their contents" do
    assert ArgumentCleaner.clean([]) == "[]"
    assert ArgumentCleaner.clean([:foo]) == "[...]"
  end

  test "cleaning small unnested keyword lists shows their cleaned contents" do
    assert ArgumentCleaner.clean(foo: :bar, baz: "quux") == "[foo: :bar, baz: \"...\"]"
    assert ArgumentCleaner.clean(a: :a, b: :b, c: :c, d: :d) == "[a: :a, b: :b, c: :c, d: :d]"
  end

  test "cleaning big unnested keyword lists omits their contents" do
    assert ArgumentCleaner.clean(a: :a, b: :b, c: :c, d: :d, e: :e) == "[...]"
  end

  test "cleaning small nested keyword lists omits their contents" do
    assert ArgumentCleaner.clean({[foo: :bar, baz: "quux"]}) == "{[...]}"
  end
end
