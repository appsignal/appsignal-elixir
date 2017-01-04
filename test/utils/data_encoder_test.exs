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
end
