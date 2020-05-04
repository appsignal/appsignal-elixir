defmodule Appsignal.Diagnose.Validation do
  @moduledoc false
  alias Appsignal.Utils.PushApiKeyValidator

  def validate(config) do
    case PushApiKeyValidator.validate(config) do
      :ok ->
        %{push_api_key: "valid"}

      {:error, :invalid} ->
        %{push_api_key: "invalid"}

      {:error, reason} ->
        %{push_api_key: "error: #{inspect(reason)}"}
    end
  end
end
