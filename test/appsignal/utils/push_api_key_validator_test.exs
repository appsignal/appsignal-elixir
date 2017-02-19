defmodule Appsignal.Utils.PushApiKeyValidatorTest do
  use ExUnit.Case
  alias Appsignal.Utils.PushApiKeyValidator

  setup do
    bypass = Bypass.open
    config = %{endpoint: "http://localhost:#{bypass.port}", push_api_key: "foo"}

    {:ok, %{bypass: bypass, config: config}}
  end

  describe "with valid push api key" do
    setup %{bypass: bypass, config: config} do
      Bypass.expect bypass, fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "")
      end

      {:ok, %{config: config}}
    end

    test "returns :ok", %{config: config} do
      assert PushApiKeyValidator.validate(config) == :ok
    end
  end

  describe "with invalid push api key" do
    setup %{bypass: bypass, config: config} do
      Bypass.expect bypass, fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 401, "")
      end

      {:ok, %{config: config}}
    end

    test "returns :invalid", %{config: config} do
      assert PushApiKeyValidator.validate(config) == {:error, :invalid}
    end
  end

  describe "with a server side error" do
    setup %{bypass: bypass, config: config} do
      Bypass.expect bypass, fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 500, "")
      end

      {:ok, %{config: config}}
    end

    test "returns an error", %{config: config} do
      assert PushApiKeyValidator.validate(config) == {:error, 500}
    end
  end

  describe "with a connection error" do
    setup %{bypass: bypass, config: config} do
      Bypass.down(bypass)
      {:ok, %{bypass: bypass, config: config}}
    end

    test "returns an error", %{bypass: bypass, config: config} do
      assert PushApiKeyValidator.validate(config) == {
        :error,
        {
          :failed_connect,
          [{:to_address, {'localhost', bypass.port}}, {:inet, [:inet], :econnrefused}]
        }
      }
    end
  end
end
