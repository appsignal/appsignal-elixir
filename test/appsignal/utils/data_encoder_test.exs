defmodule DataEncoderExampleStruct do
  defstruct foo: "bar"
end

defmodule Appsignal.Utils.DataEncoderTest do
  use ExUnit.Case
  @moduletag :skip_env_test_no_nif

  alias Appsignal.{Utils.DataEncoder, Nif}

  test "encode an empty map" do
    resource = DataEncoder.encode(%{})
    assert {:ok, '{}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a string key and value" do
    resource = DataEncoder.encode(%{"foo" => "bar"})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an atom key and string value" do
    resource = DataEncoder.encode(%{foo: "bar"})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer key and string value" do
    resource = DataEncoder.encode(%{1 => "bar"})
    assert {:ok, '{"1":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a map key and string value" do
    resource = DataEncoder.encode(%{%{foo: "bar"} => "baz"})
    assert {:ok, '{"%{foo: \\"bar\\"}":"baz"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a struct key and string value" do
    resource = DataEncoder.encode(%{%DataEncoderExampleStruct{} => "baz"})
    assert {:ok, '{"%DataEncoderExampleStruct{foo: \\"bar\\"}":"baz"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer value" do
    resource = DataEncoder.encode(%{foo: 9223372036854775807})
    assert {:ok, '{"foo":9223372036854775807}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer too big for C-lang longs to fit" do
    resource = DataEncoder.encode(%{foo: 9223372036854775808})
    assert {:ok, '{"foo":"bigint:9223372036854775808"}'} == Nif.data_to_json(resource)
    resource = DataEncoder.encode(%{foo: 9223372036854775809})
    assert {:ok, '{"foo":"bigint:9223372036854775809"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a float value" do
    resource = DataEncoder.encode(%{foo: 3.14159})
    assert {:ok, '{"foo":3.14159}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a boolean atom" do
    resource = DataEncoder.encode(%{foo: true})
    assert {:ok, '{"foo":true}'} == Nif.data_to_json(resource)

    resource = DataEncoder.encode(%{foo: false})
    assert {:ok, '{"foo":false}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a nil value" do
    resource = DataEncoder.encode(%{foo: nil})
    assert {:ok, '{"foo":null}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a map value" do
    resource = DataEncoder.encode(%{foo: %{bar: "baz"}})
    assert {:ok, '{"foo":{"bar":"baz"}}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a list value" do
    resource = DataEncoder.encode(%{foo: ["bar"]})
    assert {:ok, '{"foo":["bar"]}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an atom value" do
    resource = DataEncoder.encode(%{foo: :bar})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a tuple value" do
    resource = DataEncoder.encode(%{foo: {"foo", "bar", "baz"}})
    assert {:ok, '{"foo":["foo","bar","baz"]}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a PID value" do
    resource = DataEncoder.encode(%{foo: self()})
    assert {:ok, '{"foo":"#{inspect self()}"}'} == Nif.data_to_json(resource)
  end

  test "encode an empty list" do
    resource = DataEncoder.encode([])
    assert {:ok, '[]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a string item" do
    resource = DataEncoder.encode(["foo"])
    assert {:ok, '["foo"]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a non-string item" do
    resource = DataEncoder.encode([:bar])
    assert {:ok, '["bar"]'} == Nif.data_to_json(resource)
  end

  test "encode a list with an integer item" do
    resource = DataEncoder.encode([9223372036854775807])
    assert {:ok, '[9223372036854775807]'} == Nif.data_to_json(resource)
  end

  test "encode a list with an integer item too big for C-lang longs to fit" do
    resource = DataEncoder.encode([9223372036854775808])
    assert {:ok, '["bigint:9223372036854775808"]'} == Nif.data_to_json(resource)
    resource = DataEncoder.encode([9223372036854775809])
    assert {:ok, '["bigint:9223372036854775809"]'} == Nif.data_to_json(resource)
  end

  test "encode a list with an float item" do
    resource = DataEncoder.encode([3.14159])
    assert {:ok, '[3.14159]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a boolean atom" do
    resource = DataEncoder.encode([true])
    assert {:ok, '[true]'} == Nif.data_to_json(resource)

    resource = DataEncoder.encode([false])
    assert {:ok, '[false]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a nil item" do
    resource = DataEncoder.encode([nil])
    assert {:ok, '[null]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a map item" do
    resource = DataEncoder.encode([%{bar: "baz"}])
    assert {:ok, '[{"bar":"baz"}]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a list item" do
    resource = DataEncoder.encode(["foo", ["bar"]])
    assert {:ok, '["foo",["bar"]]'} == Nif.data_to_json(resource)
  end

  test "encode a list with an improper list as string representation" do
    resource = DataEncoder.encode([1, ["foo" | "bar"]])
    assert {:ok, '[1,"improper_list:[\\"foo\\" | \\"bar\\"]"]'} == Nif.data_to_json(resource)
  end

  test "encode a map with an improper list as string representation" do
    resource = DataEncoder.encode(%{foo: ["foo" | "bar"]})
    assert {:ok, '{"foo":"improper_list:[\\"foo\\" | \\"bar\\"]"}'} == Nif.data_to_json(resource)

    resource = DataEncoder.encode(%{foo: [1, "foo" | "bar"]})
    assert {:ok, '{"foo":"improper_list:[1, \\"foo\\" | \\"bar\\"]"}'} == Nif.data_to_json(resource)
  end

  test "encode a list with a tuple item" do
    resource = DataEncoder.encode(["foo", {"foo","bar","baz"}])
    assert {:ok, '["foo",["foo","bar","baz"]]'} == Nif.data_to_json(resource)
  end

  test "encode a list with a PID item" do
    resource = DataEncoder.encode([self()])
    assert {:ok, '["#{inspect self()}"]'} == Nif.data_to_json(resource)
  end

  test "encode a struct" do
    resource = DataEncoder.encode(%DataEncoderExampleStruct{})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end
end
