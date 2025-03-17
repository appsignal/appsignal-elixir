defmodule Appsignal.Transmitter do
  @moduledoc false

  require Logger

  def request_standalone(method, url, headers \\ [], body \\ "") do
    :application.ensure_all_started(:telemetry)

    http_client = Application.get_env(:appsignal, :http_client, Finch)
    name = :"AppsignalFinch_#{:erlang.unique_integer([:positive])}"
    {:ok, pid} = Finch.start_link(name: name)

    try do
      method
      |> http_client.build(url, headers, body)
      |> http_client.request(name, options())
    after
      Process.exit(pid, :normal)
    end
  end

  def request(method, url, headers \\ [], body \\ "") do
    http_client = Application.get_env(:appsignal, :http_client, Finch)

    method
    |> http_client.build(url, headers, body)
    |> http_client.request(AppsignalFinch, options())
  end

  def transmit(url, payload_and_format \\ {nil, nil}, config \\ nil)

  def transmit(url, nil, config) do
    transmit(url, {nil, nil}, config)
  end

  def transmit(url, {payload, format}, config) do
    do_transmit(url, {payload, format}, config, false)
  end

  def transmit(url, nil, config, standalone) do
    transmit(url, {nil, nil}, config, standalone)
  end

  def transmit(url, {payload, format}, config, standalone) do
    do_transmit(url, {payload, format}, config, standalone)
  end

  def do_transmit(url, {payload, format}, config, standalone) do
    config = config || Appsignal.Config.config()

    params =
      URI.encode_query(%{
        api_key: config[:push_api_key],
        name: config[:name],
        environment: config[:env],
        hostname: config[:hostname]
      })

    url = "#{url}?#{params}"
    headers = [{"Content-Type", "application/json; charset=UTF-8"}]

    body = encode_body(payload, format)

    request_fun = if standalone, do: &request_standalone/4, else: &request/4
    request_fun.(:post, url, headers, body)
  end

  defp encode_body(nil, _), do: ""
  defp encode_body(payload, :json), do: Jason.encode!(payload)

  defp encode_body(payload, :ndjson) do
    payload
    |> Enum.map_join("\n", &Jason.encode!/1)
  end

  defp options do
    ssl_options() ++
      [
        pool: :appsignal_transmitter
      ]
  end

  defp ssl_options do
    ca_file_path = Appsignal.Config.ca_file_path()

    options =
      case File.stat(ca_file_path) do
        {:ok, %{access: access}} when access in [:read, :read_write] ->
          {:ok,
           [
             ssl_options:
               [
                 verify: :verify_peer,
                 cacertfile: ca_file_path
               ] ++ tls_options() ++ customize_hostname_check_or_verify_fun()
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
          Logger.warning(
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
        ciphers: ciphers(),
        honor_cipher_order: :undefined
      ]
    end

    if System.otp_release() >= "20.3" do
      defp ciphers, do: :ssl.cipher_suites(:default, :"tlsv1.2")
    else
      defp ciphers, do: :ssl.cipher_suites()
    end
  end

  if System.otp_release() >= "21" do
    defp customize_hostname_check_or_verify_fun do
      [
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    end
  else
    defp customize_hostname_check_or_verify_fun do
      [
        verify_fun:
          {fn
             _, :valid, state -> {:valid, state}
             _, :valid_peer, state -> {:valid, state}
             _, {:extension, _}, state -> {:unknown, state}
             _, reason, _ -> {:fail, reason}
           end, self()}
      ]
    end
  end

  defp packaged_ca_file_path do
    Path.join(:code.priv_dir(:appsignal), "cacert.pem")
  end
end
