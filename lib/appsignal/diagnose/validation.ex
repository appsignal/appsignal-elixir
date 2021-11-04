defmodule Appsignal.Diagnose.Validation do
  @moduledoc false
  alias Appsignal.Utils.PushApiKeyValidator

  def validate(config) do
    case PushApiKeyValidator.validate(config) do
      :ok ->
        %{push_api_key: "valid"}

      {:error, :invalid} ->
        %{push_api_key: "invalid"}

      {:error, status_code} when is_number(status_code) ->
        %{push_api_key: "Failed to validate: status #{status_code}"}

      {:error, reason} ->
        %{push_api_key: "Failed to validate: #{inspect(reason)}"}
    end
  end
end
