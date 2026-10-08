defmodule Appsignal.Utils.PushApiKeyValidatorTest do
  use ExUnit.Case
  alias Appsignal.FakeTransmitter
  alias Appsignal.Utils.PushApiKeyValidator

  setup do
    start_supervised!(FakeTransmitter)
    config = %{endpoint: "http://localhost:4005", push_api_key: "foo"}

    {:ok, %{config: config}}
  end

  describe "with valid push api key" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 200, body: ""}})
    end

    test "returns :ok", %{config: config} do
      assert PushApiKeyValidator.validate(config) == :ok
      assert [{"http://localhost:4005/1/auth", nil, ^config}] = FakeTransmitter.transmitted()
    end
  end

  describe "with invalid push api key" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 401, body: ""}})
    end

    test "returns :invalid", %{config: config} do
      assert PushApiKeyValidator.validate(config) == {:error, :invalid}
      assert [{"http://localhost:4005/1/auth", nil, ^config}] = FakeTransmitter.transmitted()
    end
  end

  describe "with a server side error" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 500, body: ""}})
    end

    test "returns an error", %{config: config} do
      assert PushApiKeyValidator.validate(config) == {:error, 500}
      assert [{"http://localhost:4005/1/auth", nil, ^config}] = FakeTransmitter.transmitted()
    end
  end

  describe "with a connection error" do
    setup do
      FakeTransmitter.set_response({:error, %Mint.TransportError{reason: :econnrefused}})
    end

    test "returns an error", %{config: config} do
      assert PushApiKeyValidator.validate(config) == {:error, :econnrefused}
    end
  end
end
