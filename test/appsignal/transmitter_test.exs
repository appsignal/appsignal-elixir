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

  describe "transmit/3" do
    test "sends a request with the given configuration as query params" do
      url = "https://example.com"
      payload = %{foo: "bar"}

      config = %{
        push_api_key: "some_push_api_key",
        name: "some_name",
        env: "some_environment",
        hostname: "some_hostname"
      }

      [method, url, headers, body, _options] = Transmitter.transmit(url, {payload, :json}, config)

      assert method == :post

      # The order in which the query parameters are serialized is not
      # stable across Elixir versions.
      assert String.starts_with?(url, "https://example.com")
      assert String.contains?(url, "name=some_name")
      assert String.contains?(url, "hostname=some_hostname")
      assert String.contains?(url, "api_key=some_push_api_key")
      assert String.contains?(url, "environment=some_environment")

      assert headers == [{"Content-Type", "application/json; charset=UTF-8"}]
      assert body == "{\"foo\":\"bar\"}"
    end

    test "uses the stored configuration when no config is given" do
      with_config(
        %{
          push_api_key: "some_push_api_key",
          name: "some_name",
          env: "some_environment",
          hostname: "some_hostname"
        },
        fn ->
          [_method, url, _headers, _body, _options] =
            Transmitter.transmit("https://example.com", {%{foo: "bar"}, :json})

          # The order in which the query parameters are serialized is not
          # stable across Elixir versions.
          assert String.starts_with?(url, "https://example.com")
          assert String.contains?(url, "name=some_name")
          assert String.contains?(url, "hostname=some_hostname")
          assert String.contains?(url, "api_key=some_push_api_key")
          assert String.contains?(url, "environment=some_environment")
        end
      )
    end

    test "uses NDJSON format when specified" do
      payload = [%{foo: "bar"}, %{baz: "quux"}]

      [_method, _url, _headers, body, _options] =
        Transmitter.transmit("https://example.com", {payload, :ndjson})

      assert body == "{\"foo\":\"bar\"}\n{\"baz\":\"quux\"}"
    end

    test "uses an empty body when no payload is given" do
      [_method, _url, _headers, body, _options] = Transmitter.transmit("https://example.com")

      assert body == ""
    end
  end

  test "uses the default CA certificate" do
    [_method, _url, _headers, _body, options] =
      Transmitter.request(:get, "https://example.com")

    ssl_options = Keyword.get(options, :ssl_options)

    assert ssl_options[:verify] == :verify_peer
    assert ssl_options[:cacertfile] == Config.ca_file_path()

    if System.otp_release() >= "23" do
      assert ssl_options[:versions] == [:"tlsv1.3", :"tlsv1.2"]
      refute Keyword.has_key?(ssl_options, :depth)
      refute Keyword.has_key?(ssl_options, :ciphers)
      refute Keyword.has_key?(ssl_options, :honor_cipher_order)
    else
      refute Keyword.has_key?(ssl_options, :versions)
      assert ssl_options[:depth] == 4
      assert ssl_options[:honor_cipher_order] == :undefined

      if System.otp_release() >= "20.3" do
        assert ssl_options[:ciphers] == :ssl.cipher_suites(:default, :"tlsv1.2")
      else
        assert ssl_options[:ciphers] == :ssl.cipher_suites()
      end
    end

    if System.otp_release() >= "21" do
      assert ssl_options[:customize_hostname_check] == [
               match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
             ]

      refute Keyword.has_key?(ssl_options, :verify_fun)
    else
      assert match?(
               {fun, pid} when is_function(fun, 3) and is_pid(pid),
               ssl_options[:verify_fun]
             )

      refute Keyword.has_key?(ssl_options, :customize_hostname_check)
    end
  end

  test "uses the configured CA certificate" do
    path = "priv/cacert.pem"

    with_config(%{ca_file_path: path}, fn ->
      [_method, _url, _headers, _body, options] =
        Transmitter.request(:get, "https://example.com")

      ssl_options = Keyword.get(options, :ssl_options)
      assert ssl_options[:cacertfile] == path
    end)
  end

  test "logs a warning when the CA certificate file does not exist" do
    path = "test/fixtures/does_not_exist.pem"

    with_config(%{ca_file_path: path}, fn ->
      log =
        capture_log(fn ->
          [_method, _url, _headers, _body, options] =
            Transmitter.request(:get, "https://example.com")

          refute Keyword.has_key?(options, :ssl_options)
        end)

      # credo:disable-for-lines:2 Credo.Check.Readability.MaxLineLength
      assert log =~
               ~r/\[warn(ing)?\](\s{1,2})Ignoring non-existing or unreadable ca_file_path \(test\/fixtures\/does_not_exist\.pem\): :enoent/
    end)
  end
end
