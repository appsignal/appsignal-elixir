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

  @doc """
  Gatekeeper for Broadway v1.0.0 or above.

  The content of Broadway telemetry events changed drastically in version 1.0.0,
  where most of the current event structure was defined.

  The presence of `topology_name`, within `metadata`, is a tell that we're in
  the presence of a >=1.0.0 Broadway version.
  """
  def broadway_processor_start(_event, _measurements, metadata, _config) do
    if metadata[:topology_name] do
      do_broadway_processor_start(metadata)
    end
  end

  defp do_broadway_processor_start(metadata) do
    topology_name = topology_name(metadata[:topology_name])

    "broadway"
    |> @tracer.create_span()
    |> @span.set_name("#{topology_name}#prepare_messages")
    |> @span.set_attribute("appsignal:category", "processor.broadway")
    |> set_attribute("message_count", metadata[:messages], &length/1)
    |> set_attribute("processor", metadata[:name], &processor_name/1)
    |> set_attribute("producer", metadata[:producer], &producer_name/1)
    |> set_attribute("topology_name", topology_name)
  end

  defp producer_name({producer_module, _}), do: module_name(producer_module)
  defp producer_name(_), do: nil

  defp topology_name({:via, _module, {_registry, key}}), do: topology_name(key)
  defp topology_name(name), do: inspect(name)

  defp processor_name({:via, _module, {_registry, {_key, name}}}), do: processor_name(name)
  defp processor_name(name) when is_atom(name) or is_binary(name), do: module_name(name)
  defp processor_name(name), do: inspect(name)

  @doc """
  Gatekeeper for Broadway v1.0.0 or above.

  The content of Broadway telemetry events changed drastically in version 1.0.0,
  where most of the current event structure was defined.

  The presence of `topology_name`, within `metadata`, is a tell that we're in
  the presence of a >=1.0.0 Broadway version.
  """
  def broadway_processor_stop(_event, _measurements, metadata, _config) do
    if metadata[:topology_name] do
      do_broadway_processor_stop(metadata)
    end
  end

  def do_broadway_processor_stop(metadata) do
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

  @doc """
  Gatekeeper for Broadway v1.0.0 or above.

  The content of Broadway telemetry events changed drastically in version 1.0.0,
  where most of the current event structure was defined.

  The presence of `topology_name`, within `metadata`, is a tell that we're in
  the presence of a >=1.0.0 Broadway version.
  """
  def broadway_processor_message_start(_event, _measurements, metadata, _config) do
    if metadata[:topology_name] do
      do_broadway_processor_message_start(metadata)
    end
  end

  defp do_broadway_processor_message_start(metadata) do
    topology_name = topology_name(metadata[:topology_name])

    "broadway"
    |> @tracer.create_span()
    |> @span.set_name("#{topology_name}#handle_message")
    |> @span.set_attribute("appsignal:category", "processor_message.broadway")
    |> @span.set_sample_data("params", metadata[:message])
    |> set_attribute("processor", metadata[:name], &processor_name/1)
    |> set_attribute("producer", metadata[:producer], &producer_name/1)
    |> set_attribute("topology_name", topology_name)
  end

  @doc """
  Gatekeeper for Broadway v1.0.0 or above.

  The content of Broadway telemetry events changed drastically in version 1.0.0,
  where most of the current event structure was defined.

  The presence of `topology_name`, within `metadata`, is a tell that we're in
  the presence of a >=1.0.0 Broadway version.
  """
  def broadway_processor_message_stop(_event, _measurements, metadata, _config) do
    if metadata[:topology_name] do
      @tracer.close_span(@tracer.current_span())
    end
  end

  @doc """
  Gatekeeper for Broadway v1.0.0 or above.

  The content of Broadway telemetry events changed drastically in version 1.0.0,
  where most of the current event structure was defined.

  The presence of `topology_name`, within `metadata`, is a tell that we're in
  the presence of a >=1.0.0 Broadway version.
  """
  def broadway_processor_message_exception(event, measurements, metadata, config) do
    if metadata[:topology_name] do
      do_broadway_processor_message_exception(metadata)
      broadway_processor_message_stop(event, measurements, metadata, config)
    end
  end

  defp do_broadway_processor_message_exception(metadata) do
    @tracer.current_span()
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
  end

  defp set_attribute(span, key, value, fun \\ & &1)
  defp set_attribute(span, _key, nil, _fun), do: span
  defp set_attribute(span, key, value, fun), do: @span.set_attribute(span, key, fun.(value))
end
