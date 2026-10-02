defmodule Appsignal.Utils.PushApiKeyValidator do
  @moduledoc false
  @transmitter Application.compile_env(
                 :appsignal,
                 :appsignal_transmitter,
                 Appsignal.Transmitter
               )

  def validate(config) do
    url = "#{config[:endpoint]}/1/auth"

    case @transmitter.transmit(url, nil, config, true) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: 401}} -> {:error, :invalid}
      {:ok, %{status: status_code}} -> {:error, status_code}
      # If the error is a `Mint.TransportError`, extract the reason
      # atom from the struct.
      {:error, %{reason: reason}} -> {:error, reason}
      # Otherwise, return the error as is.
      {:error, e} -> {:error, e}
    end
  end
end
