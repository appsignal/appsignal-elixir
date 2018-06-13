defmodule Appsignal.TransmitterTest do
  use ExUnit.Case
  alias Appsignal.{Transmitter, Config}
  import AppsignalTest.Utils

  test "uses the default CA certificate" do
    path = Config.ca_file_path()

    assert [_method, _url, _headers, _body, [ssl_options: [cacertfile: ^path]]] =
             Transmitter.request(:get, "https://example.com")
  end

  test "uses the configured ca certificate" do
    path = "foo.pem"
    with_config(%{ca_file_path: path}, fn() ->
      assert [_method, _url, _headers, _body, [ssl_options: [cacertfile: ^path]]] =
              Transmitter.request(:get, "https://example.com")
    end)
  end

  test "logs a warning when the ca certificate file is not readable" do
  end

  test "logs a warning when the ca certificate file does not exist" do
  end
end
