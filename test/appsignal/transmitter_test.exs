defmodule Appsignal.TransmitterTest do
  use ExUnit.Case
  alias Appsignal.{Transmitter, Config}
  import AppsignalTest.Utils
  import ExUnit.CaptureLog

  setup do
    Application.put_env(:appsignal, :http_client, FakeHackney)

    on_exit fn() ->
      Application.delete_env(:appsignal, :http_client)
    end
  end

  test "uses the default CA certificate" do
    path = Config.ca_file_path()

    assert [_method, _url, _headers, _body, [ssl_options: [cacertfile: ^path]]] =
             Transmitter.request(:get, "https://example.com")
  end

  test "uses the configured CA certificate" do
    path = "priv/cacert.pem"

    with_config(%{ca_file_path: path}, fn ->
      assert [_method, _url, _headers, _body, [ssl_options: [cacertfile: ^path]]] =
               Transmitter.request(:get, "https://example.com")
    end)
  end

  test "logs a warning when the CA certificate file does not exist" do
    path = "test/fixtures/does_not_exist.pem"

    with_config(%{ca_file_path: path}, fn ->
      assert capture_log(fn ->
        assert [_method, _url, _headers, _body, []] =
                Transmitter.request(:get, "https://example.com")
      end) =~ "[warn]  Ignoring non-existing or unreadable ca_file_path (test/fixtures/does_not_exist.pem): :enoent"
    end)
  end

  test "logs a warning when the CA certificate file is not readable" do
    path = "test/fixtures/unreadable.pem"

    with_config(%{ca_file_path: path}, fn ->
      assert capture_log(fn ->
        assert [_method, _url, _headers, _body, []] =
                Transmitter.request(:get, "https://example.com")
      end) =~ "[warn]  Ignoring non-existing or unreadable ca_file_path (test/fixtures/unreadable.pem): \"File access is :none\""
    end)
  end
end
