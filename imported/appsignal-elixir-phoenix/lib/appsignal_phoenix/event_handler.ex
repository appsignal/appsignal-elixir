defmodule Appsignal.Phoenix.EventHandler do
  require Logger
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def attach do
    handlers = %{
      [:phoenix, :router_dispatch, :start] => &phoenix_router_dispatch_start/4,
      [:phoenix, :endpoint, :start] => &phoenix_endpoint_start/4,
      [:phoenix, :endpoint, :stop] => &phoenix_endpoint_stop/4
    }

    for {event, fun} <- handlers do
      :telemetry.attach({__MODULE__, event}, event, fun, :ok)
    end
  end

  defp phoenix_router_dispatch_start(
         _,
         _measurements,
         %{plug: controller, plug_opts: action},
         _config
       )
       when is_atom(action) do
    span = @tracer.current_span()
    name = "#{module_name(controller)}##{action}"

    Logger.debug(
      "Appsignal.Phoenix.EventHandler: Set name from event (#{inspect(span)}, #{inspect(name)}"
    )

    @span.set_name(span, name)
  end

  defp phoenix_router_dispatch_start(_event, _measurements, _metadata, _config) do
    :ok
  end

  def phoenix_endpoint_start(_event, _measurements, _metadata, _config) do
    parent = @tracer.current_span()

    span =
      "web"
      |> @tracer.create_span(parent)
      |> @span.set_name("call.phoenix_endpoint")

    Logger.debug(
      "Appsignal.Phoenix.EventHandler: Start call.phoenix_endpoint event" <>
        " with parent #{inspect(parent)} (#{inspect(span)})"
    )
  end

  defp phoenix_endpoint_stop(_event, _measurements, _metadata, _config) do
    span = @tracer.current_span()

    @tracer.close_span(@tracer.current_span())

    Logger.debug(
      "Appsignal.Phoenix.EventHandler: Stop call.phoenix_endpoint event" <>
        " (#{inspect(span)})"
    )
  end

  defp module_name("Elixir." <> module), do: module
  defp module_name(module) when is_binary(module), do: module
  defp module_name(module), do: module |> to_string() |> module_name()
end
