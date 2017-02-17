defmodule Appsignal.Utils.PushApiKeyValidator do
  def validate(config) do
    HTTPoison.start
    url = "#{config[:endpoint]}/1/auth?api_key=#{config[:push_api_key]}"
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200}} -> :ok
      {:ok, %HTTPoison.Response{status_code: 401}} -> {:error, :invalid}
      {:ok, %HTTPoison.Response{status_code: status_code}} -> {:error, status_code}
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end
end
