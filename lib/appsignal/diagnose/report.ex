defmodule Appsignal.Diagnose.ReportBehaviour do
  @moduledoc false
  @callback send(map(), map()) :: {:ok, String.t()} | {:error, map()}
end

defmodule Appsignal.Diagnose.Report do
  @moduledoc false
  @behaviour Appsignal.Diagnose.ReportBehaviour
  alias Appsignal.Transmitter

  @spec send(map(), map()) :: {:ok, String.t()} | {:error, map()}
  def send(config, report) do
    case Transmitter.transmit(
           config[:diagnose_endpoint],
           {%{diagnose: report}, :json},
           config,
           true
         ) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, response} -> {:ok, response["token"]}
          {:error, _} -> {:error, %{status_code: 200, body: body}}
        end

      {:ok, %{status: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
