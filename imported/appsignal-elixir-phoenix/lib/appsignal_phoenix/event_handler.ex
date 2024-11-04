defmodule Appsignal.Phoenix.EventHandler do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @moduledoc false

  require Logger

  def attach do
    handlers = %{
      [:phoenix, :endpoint, :start] => &__MODULE__.phoenix_endpoint_start/4,
      [:phoenix, :endpoint, :stop] => &__MODULE__.phoenix_endpoint_stop/4,
      [:phoenix, :router_dispatch, :start] => &__MODULE__.phoenix_router_dispatch_start/4,
      [:phoenix, :router_dispatch, :stop] => &__MODULE__.phoenix_router_dispatch_stop/4,
      [:phoenix, :router_dispatch, :exception] => &__MODULE__.phoenix_router_dispatch_exception/4,
      [:phoenix, :controller, :render, :start] => &__MODULE__.phoenix_template_render_start/4,
      [:phoenix, :controller, :render, :stop] => &__MODULE__.phoenix_template_render_stop/4,
      [:phoenix, :controller, :render, :exception] => &__MODULE__.phoenix_template_render_stop/4
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
          Logger.warning(
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

  def phoenix_endpoint_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  def phoenix_router_dispatch_start(_event, _measurements, _metadata, _config) do
    parent = @tracer.current_span()

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_attribute("appsignal:category", "call.phoenix_router_dispatch")
  end

  def phoenix_router_dispatch_stop(_event, _measurements, metadata, _config) do
    _root_span = set_span_data(@tracer.root_span(), metadata)

    @tracer.close_span(@tracer.current_span())
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

  defp add_error(
         span,
         conn,
         %Phoenix.ActionClauseError{module: module, function: function} = reason,
         stack
       ) do
    span
    |> @span.set_name_if_nil("#{module}##{function}")
    |> do_add_error(conn, reason, stack)
  end

  defp add_error(span, conn, reason, stack), do: do_add_error(span, conn, reason, stack)

  defp do_add_error(span, conn, reason, stack) do
    span
    |> @span.add_error(:error, reason, stack)
    |> set_span_data(%{conn: conn})
    |> @tracer.close_span()

    @tracer.ignore()
  end

  def phoenix_template_render_start(_event, _measurements, metadata, _config) do
    parent = @tracer.current_span()

    _ =
      @span.set_sample_data_if_nil(@tracer.root_span(), "tags", %{
        "phoenix_template" => metadata.template,
        "phoenix_format" => metadata.format,
        "phoenix_view" => module_name(metadata.view)
      })

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

  defp set_span_data(span, %{conn: conn} = metadata) do
    appsignal_metadata = Appsignal.Metadata.metadata(conn)

    span
    |> @span.set_name_if_nil(name(metadata))
    |> @span.set_sample_data_if_nil("params", Appsignal.Metadata.params(conn))
    |> @span.set_sample_data_if_nil("environment", appsignal_metadata)
    |> @span.set_sample_data_if_nil("session_data", Appsignal.Metadata.session(conn))
    |> @span.set_sample_data("metadata", %{
      "request_method" => appsignal_metadata["method"],
      "request_path" => appsignal_metadata["request_path"],
      "request_id" => appsignal_metadata["request_id"],
      "response_status" => appsignal_metadata["status"]
    })
  end

  defp name(%{conn: conn} = metadata) do
    Appsignal.Metadata.name(conn) || extract_name(metadata)
  end

  defp extract_name(%{conn: %{method: method}, route: route}) do
    "#{method} #{route}"
  end

  defp extract_name(_) do
    nil
  end

  defp module_name("Elixir." <> module), do: module
  defp module_name(module) when is_binary(module), do: module
  defp module_name(module), do: module |> to_string() |> module_name()
end
