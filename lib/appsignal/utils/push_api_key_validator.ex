defmodule Appsignal.Utils.PushApiKeyValidator do
  @moduledoc false
  alias Appsignal.Transmitter

  def validate(config) do
    url = "#{config[:endpoint]}/1/auth"

    case Transmitter.transmit(url, nil, config) do
      {:ok, 200, _, _} -> :ok
      {:ok, 401, _, _} -> {:error, :invalid}
      {:ok, status_code, _, _} -> {:error, status_code}
      {:error, reason} -> {:error, reason}
    end
  end
end
