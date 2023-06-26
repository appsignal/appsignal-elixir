defmodule Appsignal.Transmitter do
  @moduledoc false

  import Appsignal.Utils, only: [warning: 1]

  def request(method, url, headers \\ [], body \\ "") do
    http_client = Application.get_env(:appsignal, :http_client, :hackney)
    :application.ensure_all_started(http_client)

    http_client.request(method, url, headers, body, options())
  end

  defp options do
    ca_file_path = Appsignal.Config.ca_file_path()

    options =
      case File.stat(ca_file_path) do
        {:ok, %{access: access}} when access in [:read, :read_write] ->
          {:ok,
           [
             ssl_options:
               [
                 verify: :verify_peer,
                 cacertfile: ca_file_path,
                 customize_hostname_check: [
                   match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
                 ]
               ] ++ tls_options()
           ]}

        {:ok, %{access: access}} ->
          {:error, "File access is #{inspect(access)}"}

        {:error, reason} ->
          {:error, reason}
      end

    case options do
      {:ok, options} ->
        options

      {:error, message} ->
        unless ca_file_path == packaged_ca_file_path() do
          warning(
            "Ignoring non-existing or unreadable ca_file_path (#{ca_file_path}): #{inspect(message)}"
          )
        end

        []
    end
  end

  if System.otp_release() >= "23" do
    defp tls_options, do: [versions: :ssl.versions()[:supported]]
  else
    defp tls_options do
      [
        depth: 4,
        ciphers: :ssl.cipher_suites(:default, :"tlsv1.2"),
        honor_cipher_order: :undefined
      ]
    end
  end

  defp packaged_ca_file_path do
    Path.join(:code.priv_dir(:appsignal), "cacert.pem")
  end
end
