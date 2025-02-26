defmodule Appsignal.Utils.PushApiKeyValidator do
  @moduledoc false
  alias Appsignal.Transmitter

  def validate(config) do
    url = "#{config[:endpoint]}/1/auth"

    case Transmitter.transmit_and_close(url, nil, config, true) do
      {:ok, 200, _} -> :ok
      {:ok, 401, _} -> {:error, :invalid}
      {:ok, status_code, _} -> {:error, status_code}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end
