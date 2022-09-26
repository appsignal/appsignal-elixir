defmodule Appsignal.Finch do
  require Appsignal.Utils

  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc false

  require Logger

  def attach do
    handlers = %{
      [:finch, :request, :start] => &__MODULE__.finch_request_start/4,
      [:finch, :request, :stop] => &__MODULE__.finch_request_stop/4,
      [:finch, :request, :exception] => &__MODULE__.finch_request_exception/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ = Appsignal.Logger.debug("Appsignal.Finch attached to #{inspect(event)}")

          :ok

        {:error, _} = error ->
          Logger.warn("Appsignal.Finch not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def finch_request_start(
        _event,
        _measurements,
        %{name: name, request: request},
        _config
      ) do
    do_finch_request_start(@tracer.current_span(), name, request)
  end

  defp do_finch_request_start(nil, _name, _request), do: nil

  defp do_finch_request_start(parent, _name, request) do
    uri = %URI{
      scheme: Atom.to_string(request.scheme),
      path: request.path,
      query: request.query,
      host: request.host,
      port: request.port
    }

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name("#{request.method} #{URI.to_string(uri)}")
    |> @span.set_attribute("appsignal:category", "request.finch")
  end

  def finch_request_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  def finch_request_exception(_event, _measurements, metadata, _config) do
    @tracer.current_span()
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
    |> @tracer.close_span()

    @tracer.ignore()
  end
end
