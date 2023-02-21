defmodule Appsignal.Phoenix.EventHandler do
  require Appsignal.Utils
  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @moduledoc false

  require Logger

  def attach do
    handlers = %{
      [:phoenix, :endpoint, :start] => &__MODULE__.phoenix_endpoint_start/4,
      [:phoenix, :endpoint, :stop] => &__MODULE__.phoenix_endpoint_stop/4,
      [:phoenix, :controller, :render, :start] => &__MODULE__.phoenix_template_render_start/4,
      [:phoenix, :controller, :render, :stop] => &__MODULE__.phoenix_template_render_stop/4,
      [:phoenix, :controller, :render, :exception] => &__MODULE__.phoenix_template_render_stop/4,
      [:phoenix, :router_dispatch, :exception] => &__MODULE__.phoenix_router_dispatch_exception/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "Appsignal.Phoenix.EventHandler attached to #{inspect(event)}"
            )

          :ok

        {:error, _} = error ->
          Logger.warn(
            "Appsignal.Phoenix.EventHandler not attached to #{inspect(event)}: #{inspect(error)}"
          )

          error
      end
    end
  end

  def phoenix_endpoint_start(_event, _measurements, _metadata, _config) do
    parent = @tracer.current_span()

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_attribute("appsignal:category", "call.phoenix_endpoint")
  end

  def phoenix_endpoint_stop(_event, _measurements, %{conn: conn}, _config) do
    @tracer.current_span()
    |> Appsignal.Plug.set_conn_data(conn)
    |> @tracer.close_span()
  end

  def phoenix_router_dispatch_exception(
        _event,
        _measurements,
        %{reason: %Plug.Conn.WrapperError{conn: conn, reason: reason, stack: stack}},
        _config
      ) do
    add_error(@tracer.root_span(), conn, reason, stack)
  end

  def phoenix_router_dispatch_exception(
        _event,
        _measurements,
        %{conn: conn, reason: reason, stacktrace: stack},
        _config
      ) do
    add_error(@tracer.root_span(), conn, reason, stack)
  end

  defp add_error(span, conn, reason, stack) do
    span
    |> @span.add_error(:error, reason, stack)
    |> Appsignal.Plug.set_conn_data(conn)
    |> @tracer.close_span()

    @tracer.ignore()
  end

  def phoenix_template_render_start(_event, _measurements, metadata, _config) do
    parent = @tracer.current_span()

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name(
      "Render #{inspect(metadata.template)} (#{metadata.format}) template from #{module_name(metadata.view)}"
    )
    |> @span.set_attribute("appsignal:category", "render.phoenix_template")
  end

  def phoenix_template_render_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  defp module_name("Elixir." <> module), do: module
  defp module_name(module) when is_binary(module), do: module
  defp module_name(module), do: module |> to_string() |> module_name()
end
