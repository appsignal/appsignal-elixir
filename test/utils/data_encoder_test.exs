defmodule Appsignal.Utils.DataEncoderTest do
  use ExUnit.Case

  alias Appsignal.{Utils.DataEncoder, Nif}

  test "encode an empty map" do
    resource = DataEncoder.encode(%{})
    assert {:ok, '{}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a string key and value" do
    resource = DataEncoder.encode(%{"foo" => "bar"})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a non-string key and string value" do
    resource = DataEncoder.encode(%{foo: "bar"})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)

    resource = DataEncoder.encode(%{1 => "bar"})
    assert {:ok, '{"1":"bar"}'} == Nif.data_to_json(resource)
  end

  test "encode a map with an integer value" do
    resource = DataEncoder.encode(%{foo: 1})
    assert {:ok, '{"foo":1}'} == Nif.data_to_json(resource)
  end

  test "encode a map with a non-string value" do
    resource = DataEncoder.encode(%{foo: :bar})
    assert {:ok, '{"foo":"bar"}'} == Nif.data_to_json(resource)
  end
end
