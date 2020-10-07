defmodule Appsignal.TransmitterTest do
  use ExUnit.Case
  alias Appsignal.{Config, Transmitter}
  import AppsignalTest.Utils
  import ExUnit.CaptureLog

  setup do
    Application.put_env(:appsignal, :http_client, FakeHackney)

    on_exit(fn ->
      Application.delete_env(:appsignal, :http_client)
    end)
  end

  test "uses the default CA certificate" do
    [_method, _url, _headers, _body, [ssl_options: ssl_options]] =
      Transmitter.request(:get, "https://example.com")

    assert ssl_options[:verify] == :verify_peer
    assert ssl_options[:cacertfile] == Config.ca_file_path()
    assert ssl_options[:depth] == 4

    if System.otp_release() >= "21" do
      assert ssl_options[:customize_hostname_check] == [
               match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
             ]

      refute Keyword.has_key?(ssl_options, :verify_fun)
    else
      {fun, pid} = ssl_options[:verify_fun]
      assert is_function(fun)
      assert is_pid(pid)

      refute Keyword.has_key?(ssl_options, :customize_hostname_check)
    end

    cond do
      System.otp_release() >= "23" ->
        assert ssl_options[:ciphers] == :ssl.cipher_suites(:default, :"tlsv1.3")

      System.otp_release() >= "20.3" ->
        assert ssl_options[:ciphers] == :ssl.cipher_suites(:default, :"tlsv1.2")

      true ->
        assert ssl_options[:ciphers] == :ssl.cipher_suites()
    end

    assert ssl_options[:honor_cipher_order] == :undefined
  end

  test "uses the configured CA certificate" do
    path = "priv/cacert.pem"

    with_config(%{ca_file_path: path}, fn ->
      [_method, _url, _headers, _body, [ssl_options: ssl_options]] =
        Transmitter.request(:get, "https://example.com")

      assert ssl_options[:cacertfile] == path
    end)
  end

  test "logs a warning when the CA certificate file does not exist" do
    path = "test/fixtures/does_not_exist.pem"

    with_config(%{ca_file_path: path}, fn ->
      assert capture_log(fn ->
               assert [_method, _url, _headers, _body, []] =
                        Transmitter.request(:get, "https://example.com")
             end) =~
               "[warn]  Ignoring non-existing or unreadable ca_file_path (test/fixtures/does_not_exist.pem): :enoent"
    end)
  end
end
