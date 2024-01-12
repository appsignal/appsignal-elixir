defmodule DataEncoderExampleStruct do
  defstruct foo: "bar"
end

defmodule Appsignal.Utils.DataEncoderTest do
  use ExUnit.Case
  @moduletag :skip_env_test_no_nif

  alias Appsignal.{Nif, Utils.DataEncoder}

  test "encode an empty map" do
    resource = DataEncoder.encode(%{})
    assert {:ok, ~c"{}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a string key and value" do
    resource = DataEncoder.encode(%{"foo" => "bar"})
    assert {:ok, ~c"{\"foo\":\"bar\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with an atom key and string value" do
    resource = DataEncoder.encode(%{foo: "bar"})
    assert {:ok, ~c"{\"foo\":\"bar\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer key and string value" do
    resource = DataEncoder.encode(%{1 => "bar"})
    assert {:ok, ~c"{\"1\":\"bar\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a map key and string value" do
    resource = DataEncoder.encode(%{%{foo: "bar"} => "baz"})
    assert {:ok, ~c"{\"%{foo: \\\"bar\\\"}\":\"baz\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a struct key and string value" do
    resource = DataEncoder.encode(%{%DataEncoderExampleStruct{} => "baz"})

    assert {:ok, ~c"{\"%DataEncoderExampleStruct{foo: \\\"bar\\\"}\":\"baz\"}"} ==
             Nif.data_to_json(resource)
  end

  test "encode a map with an integer value" do
    resource = DataEncoder.encode(%{foo: 9_223_372_036_854_775_807})
    assert {:ok, ~c"{\"foo\":9223372036854775807}"} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer too big for C-lang longs to fit" do
    resource = DataEncoder.encode(%{foo: 9_223_372_036_854_775_808})
    assert {:ok, ~c"{\"foo\":\"bigint:9223372036854775808\"}"} == Nif.data_to_json(resource)
    resource = DataEncoder.encode(%{foo: 9_223_372_036_854_775_809})
    assert {:ok, ~c"{\"foo\":\"bigint:9223372036854775809\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a float value" do
    resource = DataEncoder.encode(%{foo: 3.14159})
    assert {:ok, ~c"{\"foo\":3.14159}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a boolean atom" do
    resource = DataEncoder.encode(%{foo: true})
    assert {:ok, ~c"{\"foo\":true}"} == Nif.data_to_json(resource)

    resource = DataEncoder.encode(%{foo: false})
    assert {:ok, ~c"{\"foo\":false}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a nil value" do
    resource = DataEncoder.encode(%{foo: nil})
    assert {:ok, ~c"{\"foo\":null}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a map value" do
    resource = DataEncoder.encode(%{foo: %{bar: "baz"}})
    assert {:ok, ~c"{\"foo\":{\"bar\":\"baz\"}}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a list value" do
    resource = DataEncoder.encode(%{foo: ["bar"]})
    assert {:ok, ~c"{\"foo\":[\"bar\"]}"} == Nif.data_to_json(resource)
  end

  test "encode a map with an atom value" do
    resource = DataEncoder.encode(%{foo: :bar})
    assert {:ok, ~c"{\"foo\":\"bar\"}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a tuple value" do
    resource = DataEncoder.encode(%{foo: {"foo", "bar", "baz"}})
    assert {:ok, ~c"{\"foo\":[\"foo\",\"bar\",\"baz\"]}"} == Nif.data_to_json(resource)
  end

  test "encode a map with a PID value" do
    resource = DataEncoder.encode(%{foo: self()})
    assert {:ok, ~c"{\"foo\":\"#{inspect(self())}\"}"} == Nif.data_to_json(resource)
  end

  test "encode an empty list" do
    resource = DataEncoder.encode([])
    assert {:ok, ~c"[]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a string item" do
    resource = DataEncoder.encode(["foo"])
    assert {:ok, ~c"[\"foo\"]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a non-string item" do
    resource = DataEncoder.encode([:bar])
    assert {:ok, ~c"[\"bar\"]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a keywords" do
    resource = DataEncoder.encode(foo: "some value", bar: "other value")

    assert {:ok, ~c"[[\"foo\",\"some value\"],[\"bar\",\"other value\"]]"} ==
             Nif.data_to_json(resource)
  end

  test "encode a list with a keywords with maps as values" do
    resource = DataEncoder.encode(field: {"can't be blank", [validation: :required]})

    assert {:ok, ~c"[[\"field\",[\"can't be blank\",[[\"validation\",\"required\"]]]]]"} ==
             Nif.data_to_json(resource)
  end

  test "encode a list with an integer item" do
    resource = DataEncoder.encode([9_223_372_036_854_775_807])
    assert {:ok, ~c"[9223372036854775807]"} == Nif.data_to_json(resource)
  end

  test "encode a list with an integer item too big for C-lang longs to fit" do
    resource = DataEncoder.encode([9_223_372_036_854_775_808])
    assert {:ok, ~c"[\"bigint:9223372036854775808\"]"} == Nif.data_to_json(resource)
    resource = DataEncoder.encode([9_223_372_036_854_775_809])
    assert {:ok, ~c"[\"bigint:9223372036854775809\"]"} == Nif.data_to_json(resource)
  end

  test "encode a list with an float item" do
    resource = DataEncoder.encode([3.14159])
    assert {:ok, ~c"[3.14159]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a boolean atom" do
    resource = DataEncoder.encode([true])
    assert {:ok, ~c"[true]"} == Nif.data_to_json(resource)

    resource = DataEncoder.encode([false])
    assert {:ok, ~c"[false]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a nil item" do
    resource = DataEncoder.encode([nil])
    assert {:ok, ~c"[null]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a map item" do
    resource = DataEncoder.encode([%{bar: "baz"}])
    assert {:ok, ~c"[{\"bar\":\"baz\"}]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a list item" do
    resource = DataEncoder.encode(["foo", ["bar"]])
    assert {:ok, ~c"[\"foo\",[\"bar\"]]"} == Nif.data_to_json(resource)
  end

  test "encode a list with an improper list as string representation" do
    resource = DataEncoder.encode([1, ["foo" | "bar"]])

    assert {:ok, ~c"[1,\"improper_list:[\\\"foo\\\" | \\\"bar\\\"]\"]"} ==
             Nif.data_to_json(resource)
  end

  test "encode a map with an improper list as string representation" do
    resource = DataEncoder.encode(%{foo: ["foo" | "bar"]})

    assert {:ok, ~c"{\"foo\":\"improper_list:[\\\"foo\\\" | \\\"bar\\\"]\"}"} ==
             Nif.data_to_json(resource)

    resource = DataEncoder.encode(%{foo: [1, "foo" | "bar"]})

    assert {:ok, ~c"{\"foo\":\"improper_list:[1, \\\"foo\\\" | \\\"bar\\\"]\"}"} ==
             Nif.data_to_json(resource)
  end

  test "encode a list with a tuple item" do
    resource = DataEncoder.encode(["foo", {"foo", "bar", "baz"}])
    assert {:ok, ~c"[\"foo\",[\"foo\",\"bar\",\"baz\"]]"} == Nif.data_to_json(resource)
  end

  test "encode a list with a PID item" do
    resource = DataEncoder.encode([self()])
    assert {:ok, ~c"[\"#{inspect(self())}\"]"} == Nif.data_to_json(resource)
  end

  test "encode a struct" do
    resource = DataEncoder.encode(%DataEncoderExampleStruct{})
    assert {:ok, ~c"{\"foo\":\"bar\"}"} == Nif.data_to_json(resource)
  end
end
