defmodule Appsignal.Diagnose.ReportBehaviour do
  @callback send(Appsignal.Config.t, %{}) :: {:ok, String.t}
end

defmodule Appsignal.Diagnose.Report do
  @behaviour Appsignal.Diagnose.ReportBehaviour

  def send(config, report) do
    HTTPoison.start
    params = URI.encode_query(%{
      api_key: config[:push_api_key],
      name: config[:name],
      environment: config[:environment],
      hostname: config[:hostname]
    })
    url = "#{config[:diagnose_endpoint]}?#{params}"
    body = Poison.encode!(%{diagnose: report})
    headers = [{"Content-Type", "application/json; charset=UTF-8"}]
    case HTTPoison.post url, body, headers do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, response} -> {:ok, response["token"]}
          {:error, _} -> {:error, %{status_code: 200, body: body}}
        end
      {_, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}
    end
  end
end
