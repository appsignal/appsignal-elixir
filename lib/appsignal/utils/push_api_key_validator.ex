defmodule Appsignal.Utils.PushApiKeyValidator do
  def validate(config) do
    url = "#{config[:endpoint]}/1/auth?api_key=#{config[:push_api_key]}"

    case :hackney.request(:get, url) do
      {:ok, 200, _, _} -> :ok
      {:ok, 401, _, _} -> {:error, :invalid}
      {:ok, status_code, _, _} -> {:error, status_code}
      {:error, reason} -> {:error, reason}
    end
  end
end
