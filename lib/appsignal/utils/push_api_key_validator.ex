defmodule Appsignal.Utils.PushApiKeyValidator do
  alias Appsignal.Transmitter

  def validate(config) do
    url = "#{config[:endpoint]}/1/auth?api_key=#{config[:push_api_key]}"

    case Transmitter.request(:get, url) do
      {:ok, %{status_code: 200}} -> :ok
      {:ok, %{status_code: 401}} -> {:error, :invalid}
      {:ok, %{status_code: status_code}} -> {:error, status_code}
      {:error, reason} -> {:error, reason}
    end
  end
end
