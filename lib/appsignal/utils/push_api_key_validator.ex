defmodule Appsignal.Utils.PushApiKeyValidator do
  @moduledoc false
  alias Appsignal.Transmitter

  def validate(config) do
    params =
      URI.encode_query(%{
        "api_key" => config[:push_api_key],
        "name" => config[:name],
        "environment" => config[:env],
        "hostname" => config[:hostname]
      })

    url = "#{config[:endpoint]}/1/auth?#{params}"

    case Transmitter.request(:post, url) do
      {:ok, 200, _, _} -> :ok
      {:ok, 401, _, _} -> {:error, :invalid}
      {:ok, status_code, _, _} -> {:error, status_code}
      {:error, reason} -> {:error, reason}
    end
  end
end
