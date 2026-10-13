defmodule Appsignal.Finch do
  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc false

  def attach do
    if Appsignal.Dependencies.match?(:finch, ">= 0.12.0"), do: attach_handlers(), else: []
  end

  defp attach_handlers do
    handlers = %{
      [:finch, :request, :start] => &__MODULE__.finch_request_start/4,
      [:finch, :request, :stop] => &__MODULE__.finch_request_stop/4,
      [:finch, :request, :exception] => &__MODULE__.finch_request_stop/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Finch attached to #{inspect(event)}")

          :ok

        {:error, _} = error ->
          Logger.warning("Appsignal.Finch not attached to #{inspect(event)}: #{inspect(error)}")

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
    if !has_prefix(name, "AppsignalFinch") do
      do_finch_request_start(@tracer.current_span(), name, request)
    end
  end

  defp do_finch_request_start(nil, _name, _request), do: nil

  defp do_finch_request_start(parent, _name, request) do
    uri = %URI{scheme: Atom.to_string(request.scheme), host: request.host, port: request.port}

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name("#{request.method} #{uri}")
    |> @span.set_attribute("appsignal:category", "request.finch")
  end

  def finch_request_stop(_event, _measurements, %{name: name, request: _request}, _config) do
    if !has_prefix(name, "AppsignalFinch") do
      if span = @tracer.current_span() do
        @tracer.close_span(span)
      end
    end
  end

  defp has_prefix(name, prefix) when is_atom(name) do
    atom_string = Atom.to_string(name)

    if String.starts_with?(atom_string, "Elixir.") do
      module_name = String.replace_prefix(atom_string, "Elixir.", "")
      String.starts_with?(module_name, prefix)
    else
      String.starts_with?(atom_string, prefix)
    end
  end

  defp has_prefix(name, prefix) when is_binary(name) do
    name
    |> String.starts_with?(prefix)
  end
end
