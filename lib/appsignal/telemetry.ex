defmodule Appsignal.Telemetry do
  require Appsignal.Utils

  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  require Logger

  def attach(module, handlers) do
    for {event, fun} <- handlers do
      case :telemetry.attach({module, event}, event, fun, :ok) do
        :ok ->
          _ = Appsignal.Logger.debug("#{module} attached to #{inspect(event)}")

          :ok

        {:error, _} = error ->
          Logger.warn("#{module} not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def start(name, category) do
    do_start(@tracer.current_span(), name, category)
  end

  defp do_start(nil, _name, _category), do: nil

  defp do_start(parent, name, category) do
    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name(name)
    |> @span.set_attribute("appsignal:category", category)
  end

  def stop(_evenT, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  def exception(_event, _measurements, metadata, _config) do
    @tracer.current_span()
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
    |> @tracer.close_span()

    @tracer.ignore()
  end
end
