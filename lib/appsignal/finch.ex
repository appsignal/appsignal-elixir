defmodule Appsignal.Finch do
  require Appsignal.Utils

  @moduledoc false

  def attach do
    Appsignal.Telemetry.attach(
      __MODULE__,
      %{
        [:finch, :request, :start] => &__MODULE__.finch_request_start/4,
        [:finch, :request, :stop] => &Appsignal.Telemetry.stop/4,
        [:finch, :request, :exception] => &Appsignal.Telemetry.exception/4
      }
    )
  end

  def finch_request_start(_event, _measurements, %{request: request}, _config) do
    uri = %URI{
      scheme: Atom.to_string(request.scheme),
      path: request.path,
      query: request.query,
      host: request.host,
      port: request.port
    }

    Appsignal.Telemetry.start("#{request.method} #{URI.to_string(uri)}", "request.finch")
  end
end
