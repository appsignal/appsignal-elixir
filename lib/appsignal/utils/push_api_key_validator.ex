defmodule Appsignal.Utils.PushApiKeyValidator do
  def validate(config) do
    case send_validation_request(config) do
      {:ok, {{_version, 200, _reason}, _headers, _body}} -> :ok
      {:ok, {{_version, 401, _reason}, _headers, _body}} -> {:error, :invalid}
      {:ok, {{_version, status, _reason}, _headers, _body}} -> {:error, status}
      {:error, reason} -> {:error, reason}
    end
  end

  defp send_validation_request(config) do
    url = "#{config[:endpoint]}/1/auth?api_key=#{config[:push_api_key]}"
    :inets.start
    uri = URI.parse(config[:endpoint])

    :httpc.request(
      :get,
      {to_charlist(url), []},
      [
        ssl: [
          verify: :verify_peer,
          cacerts: :certifi.cacerts,
          verify_fun: {&:ssl_verify_hostname.verify_fun/3, [:check_hostname, uri.host]},
          depth: 99
        ]
      ],
      []
    )
  end
end
