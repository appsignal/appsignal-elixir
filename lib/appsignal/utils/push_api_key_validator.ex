defmodule Appsignal.Utils.PushApiKeyValidator do
  def validate(config) do
    :inets.start

    url = "#{config[:endpoint]}/1/auth?api_key=#{config[:push_api_key]}"

    case :httpc.request(to_charlist(url)) do
      {:ok, {{_version, 200, _reason}, _headers, _body}} -> :ok
      {:ok, {{_version, 401, _reason}, _headers, _body}} -> {:error, :invalid}
      {:ok, {{_version, status, _reason}, _headers, _body}} -> {:error, status}
      {:error, reason} -> {:error, reason}
    end
  end
end
