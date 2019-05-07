defmodule Appsignal.Transmitter do
  require Logger

  def request(method, url, headers \\ [], body \\ "") do
    do_request(URI.parse(url).scheme, method, url, headers, body)
  end

  defp do_request("http", method, url, headers, body) do
    http_client().request(method, url, headers, body)
  end

  defp do_request("https", method, url, headers, body) do
    http_client().request(method, url, headers, body, options())
  end

  defp http_client do
    Application.get_env(:appsignal, :http_client, Mojito)
  end

  defp options do
    ca_file_path = Appsignal.Config.ca_file_path()

    options =
      case File.stat(ca_file_path) do
        {:ok, %{access: access}} when access in [:read, :read_write] ->
          {:ok, [transport_opts: [cacertfile: ca_file_path]]}

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
          Logger.warn(
            "Ignoring non-existing or unreadable ca_file_path (#{ca_file_path}): #{
              inspect(message)
            }"
          )
        end

        []
    end
  end

  defp packaged_ca_file_path do
    Path.join(:code.priv_dir(:appsignal), "cacert.pem")
  end
end
