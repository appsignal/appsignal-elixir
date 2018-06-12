defmodule Appsignal.Diagnose.ReportBehaviour do
  @callback send(%{}, %{}) :: {:ok | :error, String.t}
end

defmodule Appsignal.Diagnose.Report do
  alias Appsignal.Transmitter

  @behaviour Appsignal.Diagnose.ReportBehaviour

  @spec send(%{}, %{}) :: {:ok | :error, String.t}
  def send(config, report) do
    params =
      URI.encode_query(%{
        api_key: config[:push_api_key],
        name: config[:name],
        environment: config[:environment],
        hostname: config[:hostname]
      })

    url = "#{config[:diagnose_endpoint]}?#{params}"
    body = Poison.encode!(%{diagnose: report})
    headers = [{"Content-Type", "application/json; charset=UTF-8"}]

    case Transmitter.request(:post, url, headers, body) do
      {:ok, 200, _, reference} ->
        {:ok, body} = :hackney.body(reference)

        case Poison.decode(body) do
          {:ok, response} -> {:ok, response["token"]}
          {:error, _} -> {:error, %{status_code: 200, body: body}}
        end

      {:ok, status_code, _, reference} ->
        {:ok, body} = :hackney.body(reference)
        {:error, %{status_code: status_code, body: body}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
