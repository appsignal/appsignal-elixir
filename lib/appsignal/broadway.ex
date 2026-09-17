defmodule Appsignal.Broadway do
  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  import Appsignal.Utils, only: [module_name: 1]

  @moduledoc false

  def attach do
    handlers = %{
      [:broadway, :processor, :start] => &__MODULE__.broadway_processor_start/4,
      [:broadway, :processor, :stop] => &__MODULE__.broadway_processor_stop/4,
      [:broadway, :processor, :message, :start] => &__MODULE__.broadway_processor_message_start/4,
      [:broadway, :processor, :message, :stop] => &__MODULE__.broadway_processor_message_stop/4,
      [:broadway, :processor, :message, :exception] =>
        &__MODULE__.broadway_processor_message_exception/4
    }

    for {event, fun} <- handlers do
      detach = :telemetry.detach({__MODULE__, event})
      attach = :telemetry.attach({__MODULE__, event}, event, fun, :ok)

      case {detach, attach} do
        {:ok, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "Appsignal.Broadway reattached to #{inspect(event)}"
            )

          :ok

        {{:error, :not_found}, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug("Appsignal.Broadway attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Logger.warning(
            "Appsignal.Broadway not attached to #{inspect(event)}: #{inspect(error)}"
          )

          error
      end
    end
  end

  def broadway_processor_start(_event, _measurements, metadata, _config) do
    do_broadway_processor_start(metadata)
  end

  defp do_broadway_processor_start(metadata) do
    producer_name = producer_name(metadata[:producer])

    "broadway"
    |> @tracer.create_span()
    |> @span.set_name("#{producer_name}#prepare_messages")
    |> @span.set_attribute("appsignal:category", "processor.broadway")
    |> set_attribute("message_count", metadata[:messages], &length/1)
    |> set_attribute("processor", metadata[:name], &module_name/1)
    |> set_attribute("producer", producer_name)
    |> set_attribute("topology_name", metadata[:topology_name], &inspect/1)
  end

  defp producer_name({producer_module, _}), do: module_name(producer_module)
  defp producer_name(_), do: nil

  def broadway_processor_stop(_event, _measurements, metadata, _config) do
    @tracer.current_span()
    |> set_attribute("failed_messages", metadata[:failed_messages], &length/1)
    |> set_attribute(
      "successful_messages_to_ack",
      metadata[:successful_messages_to_ack],
      &length/1
    )
    |> set_attribute(
      "successful_messages_to_forward",
      metadata[:successful_messages_to_forward],
      &length/1
    )
    |> @tracer.close_span()
  end

  def broadway_processor_message_start(_event, _measurements, metadata, _config) do
    do_broadway_processor_message_start(metadata)
  end

  defp do_broadway_processor_message_start(metadata) do
    producer_name = producer_name(metadata[:producer])

    "broadway"
    |> @tracer.create_span()
    |> @span.set_name("#{producer_name}#handle_message")
    |> @span.set_attribute("appsignal:category", "processor_message.broadway")
    |> set_attribute("message", metadata[:message], &inspect/1)
    |> set_attribute("processor", metadata[:name], &module_name/1)
    |> set_attribute("producer", producer_name)
    |> set_attribute("topology_name", metadata[:topology_name], &inspect/1)
  end

  def broadway_processor_message_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end

  def broadway_processor_message_exception(event, measurements, metadata, config) do
    do_broadway_processor_message_exception(metadata)
    broadway_processor_message_stop(event, measurements, metadata, config)
  end

  defp do_broadway_processor_message_exception(metadata) do
    @tracer.current_span()
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
  end

  defp set_attribute(span, key, value, fun \\ & &1)
  defp set_attribute(span, _key, nil, _fun), do: span
  defp set_attribute(span, key, value, fun), do: @span.set_attribute(span, key, fun.(value))
end
